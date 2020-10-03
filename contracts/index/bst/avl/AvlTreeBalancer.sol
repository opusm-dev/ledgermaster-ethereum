pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import '../NodeRepository.sol';
import '../TreeBalancer.sol';
import '../TreeNode.sol';
import '../TreeNodeDetails.sol';
import '../TreeNodeUtils.sol';

import '../../../common/Comparator.sol';
import '../../../common/proxy/Controlled.sol';

contract AvlTreeBalancer is TreeBalancer, Controlled {
  TreeNode DUMMY_NODE = TreeNode({
    kind: 0,
    key: '',
    values: new string[](0),
    left: '',
    right: ''
  });

  constructor(address _controller) Controlled(_controller) public { }

  function balance(NodeRepository repository) public override {
    repository.setRoot(balance(repository, repository.getRoot()));
  }

  function balance(NodeRepository repository, TreeNode memory _node) public returns (TreeNode memory) {
    if (!TreeNodeUtils.isAvailable(_node)) {
      return _node;
    }

    TreeNodeDetails memory d = repository.details(_node);
    if (d.isBalanced) {
      return _node;
    }
    bool lb = (d.leftHeight<0) || d.isLeftBalanced;
    bool rb = (d.rightHeight<0) || d.isRightBalanced;
    if (lb && rb) {
      Comparator comparator = Comparator(getModule(COMPARATOR));
      if (1 < d.bf) {
        TreeNode memory l = repository.left(_node);
        TreeNodeDetails memory ld = repository.details(l);
        if (ld.bf < 0) {
          TreeNode memory newLeft = lrotate(repository, l);
          if (comparator.notEquals(newLeft.key, _node.left)) {
            _node = TreeNodeUtils.linkLeft(_node, newLeft.key);
            repository.set(_node);
          }
        }
        return rrotate(repository, _node);
      } else if (d.bf < -1) {
        TreeNode memory r = repository.right(_node);
        TreeNodeDetails memory rd = repository.details(r);
        if (0 < rd.bf) {
          TreeNode memory newRight = rrotate(repository, r);
          if (comparator.notEquals(newRight.key, _node.right)) {
            _node = TreeNodeUtils.linkRight(_node, newRight.key);
            repository.set(_node);
          }
        }
        return lrotate(repository, _node);
      }
    } else if (lb) {
      // Only left is balanced
      _node = TreeNodeUtils.linkRight(_node, balance(repository, repository.right(_node)).key);
      repository.set(_node);
    } else if (rb) {
      // Only right is balanced
      _node = TreeNodeUtils.linkLeft(_node, balance(repository, repository.left(_node)).key);
      repository.set(_node);
    } else {
      // Illegal State
      require(false);
    }
    return _node;
  }

  function lrotate(NodeRepository repository, TreeNode memory _node) private returns (TreeNode memory) {
    if (TreeNodeUtils.isAvailable(_node)) {
      if (TreeNodeUtils.hasRight(_node)) {
        TreeNode memory pivot = repository.get(_node.right);
        if (TreeNodeUtils.hasLeft(pivot)) {
          TreeNode memory moving = repository.get(pivot.left);
          _node = TreeNodeUtils.unlinkRight(_node);
          pivot = TreeNodeUtils.unlinkLeft(pivot);
          pivot = TreeNodeUtils.linkLeft(pivot, _node.key);
          _node = TreeNodeUtils.linkRight(_node, moving.key);
        } else {
          _node = TreeNodeUtils.unlinkRight(_node);
          pivot = TreeNodeUtils.linkLeft(pivot, _node.key);
        }
        repository.set(_node);
        repository.set(pivot);
        return pivot;
      } else {
        return DUMMY_NODE;
      }
    } else {
      return DUMMY_NODE;
    }
  }

  function rrotate(NodeRepository repository, TreeNode memory _node) private returns (TreeNode memory) {
    if (TreeNodeUtils.isAvailable(_node)) {
      if (TreeNodeUtils.hasLeft(_node)) {
        TreeNode memory pivot = repository.get(_node.left);
        if (TreeNodeUtils.hasRight(pivot)) {
          TreeNode memory moving = repository.get(pivot.right);
          _node = TreeNodeUtils.unlinkLeft(_node);
          pivot = TreeNodeUtils.unlinkRight(pivot);
          pivot = TreeNodeUtils.linkRight(pivot, _node.key);
          _node = TreeNodeUtils.linkLeft(_node, moving.key);
        } else {
          _node = TreeNodeUtils.unlinkLeft(_node);
          pivot = TreeNodeUtils.linkRight(pivot, _node.key);
        }
        repository.set(_node);
        repository.set(pivot);
        return pivot;
      } else {
        return DUMMY_NODE;
      }
    } else {
      return DUMMY_NODE;
    }
  }
}