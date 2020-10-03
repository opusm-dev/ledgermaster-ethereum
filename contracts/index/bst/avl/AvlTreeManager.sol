pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../TreeNodeUtils.sol';
import '../TreeNode.sol';
import '../NodeManager.sol';
import '../NodeRepository.sol';

import '../../../common/Comparator.sol';
import '../../../common/proxy/Controlled.sol';

contract AvlTreeManager is NodeManager, Controlled {
  string private constant ERR_ILLEGAL_STATE = 'CTR_ILLEGAL_STATE';

  constructor(address _controller) Controlled(_controller) public { }

  TreeNode DUMMY_NODE = TreeNode({
    kind: 0,
    key: '',
    values: new string[](0),
    left: '',
    right: ''
    });

  function add(NodeRepository repository, string memory _key, string memory _value) public override {
    TreeNode memory node = repository.get(_key);
    if (TreeNodeUtils.isAvailable(node)) {
      repository.add(_key, _value);
    } else {
      addNode(repository, _key, _value);
      balance(repository);
    }
  }

  function addNode(NodeRepository repository, string memory _key, string memory _value)
  public {
    TreeNode memory r = repository.getRoot();
    repository.create(_key);
    repository.add(_key, _value);
    if (TreeNodeUtils.isAvailable(r)) {
      TreeNode[] memory path = repository.find(NODE_FINDER, _key);
      if (0 < path.length) {
        TreeNode memory node = path[path.length - 1];
        // node는 값이 결코 매칭되지 않는다.
        Comparator comparator = Comparator(getModule(COMPARATOR));
        int comparison = comparator.compare(node.key, _key);
        if (comparison < 0) {
          node = TreeNodeUtils.linkRight(node, _key);
        } else if (0 < comparison) {
          node = TreeNodeUtils.linkLeft(node, _key);
        } else {
          require(false, ERR_ILLEGAL_STATE);
        }
        repository.set(node);
      }
    } else {
      // 첫번째 노드
      repository.setRoot(repository.get(_key));
    }
  }

  function remove(NodeRepository repository, string memory _key, string memory _value) public override {
    if (0 == repository.remove(_key, _value)) {
      TreeNode memory newRoot = removeNode(repository, repository.getRoot().key, _key);
      repository.setRoot(newRoot);
      balance(repository);
    }
  }

  function removeNode(NodeRepository repository, string memory _base, string memory _key) private returns (TreeNode memory) {
    TreeNode memory node = repository.get(_base);
    if (!TreeNodeUtils.isAvailable(node)) {
      return DUMMY_NODE;
    }
    Comparator comparator = Comparator(getModule(COMPARATOR));
    int comparison = comparator.compare(node.key, _key);
    if (comparison < 0) {
      TreeNode memory newRight = removeNode(repository, node.right, _key);
      if (!TreeNodeUtils.isAvailable(newRight)) {
        node = TreeNodeUtils.unlinkRight(node);
        repository.set(node);
      } else if (comparator.notEquals(newRight.key, node.right)) {
        node = TreeNodeUtils.linkRight(node, newRight.key);
        repository.set(node);
      }
      return node;
    } else if (0 < comparison) {
      TreeNode memory newLeft = removeNode(repository, node.left, _key);
      if (!TreeNodeUtils.isAvailable(newLeft)) {
        node = TreeNodeUtils.unlinkLeft(node);
        repository.set(node);
      } else if (comparator.notEquals(newLeft.key, node.left)) {
        node = TreeNodeUtils.linkLeft(node, newLeft.key);
        repository.set(node);
      }
      return node;
    } else if (0 == comparison) {
      if (TreeNodeUtils.hasLeft(node)) {
        if (TreeNodeUtils.hasRight(node)) {
          TreeNode memory newNode = min(repository, repository.right(node));
          newNode = TreeNodeUtils.linkLeft(newNode, node.left);
          TreeNode memory r = removeNode(repository, node.right, newNode.key);
          if (TreeNodeUtils.isAvailable(r)) {
            newNode = TreeNodeUtils.linkRight(newNode, r.key);
          }
          repository.set(newNode);
          return newNode;
        } else {
          TreeNode memory left = repository.left(node);
          repository.remove(_key);
          return left;
        }
      } else {
        if (TreeNodeUtils.hasRight(node)) {
          TreeNode memory right = repository.right(node);
          repository.remove(_key);
          return right;
        } else {
          repository.remove(_key);
          return DUMMY_NODE;
        }
      }
    } else {
      require(false);
    }
    return DUMMY_NODE;
  }

  function balance(NodeRepository repository) private {
    (bool success, ) = getModule(BALANCER).delegatecall(abi.encodeWithSignature('balance(address)', repository));
    require(success, 'Fail to balance');
  }

  function min(NodeRepository repository, TreeNode memory _node) private view returns (TreeNode memory) {
    TreeNode[] memory path = repository.find(MIN_FINDER, _node, '');
    return (0 < path.length) ? path[path.length - 1] : DUMMY_NODE;
  }

}

