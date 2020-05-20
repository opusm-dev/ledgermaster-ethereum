pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import "../lib/system.sol";
import "../lib/tree.sol";

import "../NodeRepository.sol";
import "../Balancer.sol";

contract AvlTreeBalancer is Balancer {
  tree.Node DUMMY_NODE = tree.Node({
    kind: 0,
    key: '',
    values: new string[](0),
    left: '',
    right: ''
  });

  event UnbalanceDetected(string key, int bf);
  event NodeTraverse(tree.Node node);

  function balance(NodeRepository repository) public override {
    repository.setRoot(balance(repository, repository.getRoot()));
  }

  function balance(NodeRepository repository, tree.Node memory _node) public returns (tree.Node memory) {
    if (!tree.isAvailable(_node)) {
      return _node;
    }

    emit NodeTraverse(_node);
    tree.NodeDetails memory d = repository.details(_node);
    if (d.isBalanced) {
      return _node;
    }
    bool lb = (d.leftHeight<0) || d.isLeftBalanced;
    bool rb = (d.rightHeight<0) || d.isRightBalanced;
    if (lb && rb) {
      emit UnbalanceDetected(_node.key, d.bf);
      if (1 < d.bf) {
        tree.Node memory l = repository.left(_node);
        tree.NodeDetails memory ld = repository.details(l);
        if (ld.bf < 0) {
          tree.Node memory newLeft = lrotate(repository, l);
          if (utils.notEquals(newLeft.key, _node.left)) {
            _node = tree.linkLeft(_node, newLeft.key);
            repository.set(_node);
          }
        }
        return rrotate(repository, _node);
      } else if (d.bf < -1) {
        tree.Node memory r = repository.right(_node);
        tree.NodeDetails memory rd = repository.details(r);
        if (0 < rd.bf) {
          tree.Node memory newRight = rrotate(repository, r);
          if (utils.notEquals(newRight.key, _node.right)) {
            _node = tree.linkRight(_node, newRight.key);
            repository.set(_node);
          }
        }
        return lrotate(repository, _node);
      }
    } else if (lb) {
      // Only left is balanced
      _node = tree.linkRight(_node, balance(repository, repository.right(_node)).key);
      repository.set(_node);
    } else if (rb) {
      // Only right is balanced
      _node = tree.linkLeft(_node, balance(repository, repository.left(_node)).key);
      repository.set(_node);
    } else {
      // Illegal State
      require(false);
    }
    return _node;
  }

  function lrotate(NodeRepository repository, tree.Node memory _node) private returns (tree.Node memory) {
    if (tree.isAvailable(_node)) {
      if (tree.hasRight(_node)) {
        tree.Node memory pivot = repository.get(_node.right);
        _node = tree.linkRight(_node, pivot.left);
        pivot = tree.linkLeft(pivot, _node.key);
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

  function rrotate(NodeRepository repository, tree.Node memory _node) private returns (tree.Node memory) {
    if (tree.isAvailable(_node)) {
      if (tree.hasLeft(_node)) {
        tree.Node memory pivot = repository.get(_node.left);
        _node = tree.linkLeft(_node, pivot.right);
        pivot = tree.linkRight(pivot, _node.key);
        repository.set(pivot);
        repository.set(_node);
        return pivot;
      } else {
        return DUMMY_NODE;
      }
    } else {
      return DUMMY_NODE;
    }
  }
}