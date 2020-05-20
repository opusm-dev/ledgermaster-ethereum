pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "../NodeManager.sol";
import "../NodeRepository.sol";
import "../proxy/Modules.sol";
import "../lib/system.sol";
import "../lib/tree.sol";
import "../proxy/Controller.sol";

contract AvlTreeNodeManager is NodeManager, Controller, Modules {
  string private constant ERR_ILLEGAL_STATE = "CTR_ILLEGAL_STATE";
  event PathFound(tree.Node[] path);
  event NodeTraverseForRemove(string key, string remove);

  tree.Node DUMMY_NODE = tree.Node({
    kind: 0,
    key: '',
    values: new string[](0),
    left: '',
    right: ''
    });

  function add(NodeRepository repository, string memory _key, string memory _value) public override {
    tree.Node memory node = repository.get(_key);
    if (tree.isAvailable(node)) {
      repository.add(_key, _value);
    } else {
      addNode(repository, _key, _value);
      balance(repository);
    }
  }

  function addNode(NodeRepository repository, string memory _key, string memory _value)
  public {
    tree.Node memory r = repository.getRoot();
    repository.create(_key);
    repository.add(_key, _value);
    if (tree.isAvailable(r)) {
      tree.Node[] memory path = repository.find(NODE_FINDER, _key);
      emit PathFound(path);
      if (0 < path.length) {
        tree.Node memory node = path[path.length - 1];
        // node는 값이 결코 매칭되지 않는다.
        int comparison = utils.compare(node.key, _key);
        if (comparison < 0) {
          node = tree.linkRight(node, _key);
        } else if (0 < comparison) {
          node = tree.linkLeft(node, _key);
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
      tree.Node memory newRoot = removeNode(repository, repository.getRoot().key, _key);
      repository.setRoot(newRoot);
      balance(repository);
    }
  }

  function removeNode(NodeRepository repository, string memory _base, string memory _key) private returns (tree.Node memory) {
    tree.Node memory node = repository.get(_base);
    if (!tree.isAvailable(node)) {
      return DUMMY_NODE;
    }
    emit NodeTraverseForRemove(_base, _key);
    int comparision = utils.compare(node.key, _key);
    if (comparision < 0) {
      tree.Node memory newRight = removeNode(repository, node.right, _key);
      if (!tree.isAvailable(newRight)) {
        node = tree.unlinkRight(node);
        repository.set(node);
      } else if (utils.notEquals(newRight.key, node.right)) {
        node = tree.linkRight(node, newRight.key);
        repository.set(node);
      }
      return node;
    } else if (0 < comparision) {
      tree.Node memory newLeft = removeNode(repository, node.left, _key);
      if (!tree.isAvailable(newLeft)) {
        node = tree.unlinkLeft(node);
        repository.set(node);
      } else if (utils.notEquals(newLeft.key, node.left)) {
        node = tree.linkLeft(node, newLeft.key);
        repository.set(node);
      }
      return node;
    } else if (0 == comparision) {
      if (tree.hasLeft(node)) {
        if (tree.hasRight(node)) {
          tree.Node memory newNode = min(repository, repository.right(node));
          newNode = tree.linkLeft(newNode, node.left);
          tree.Node memory r = removeNode(repository, node.right, newNode.key);
          if (tree.isAvailable(r)) {
            newNode = tree.linkRight(newNode, r.key);
          }
          repository.set(newNode);
          return newNode;
        } else {
          return repository.left(node);
        }
      } else {
        if (tree.hasRight(node)) {
          return repository.right(node);
        } else {
          repository.remove(_base);
          return DUMMY_NODE;
        }
      }
    } else {
      require(false);
    }
    return DUMMY_NODE;
  }

  function balance(NodeRepository repository) private {
    require(address(0x0) != getModule(BALANCER), ERR_NO_MODULE);
    (bool success, ) = getModule(BALANCER).delegatecall(abi.encodeWithSignature("balance(address)", repository));
    require(success, "Fail to balance");
  }

  function min(NodeRepository repository, tree.Node memory _node) private view returns (tree.Node memory) {
    tree.Node[] memory path = repository.find(MIN_FINDER, _node, '');
    return (0 < path.length) ? path[path.length - 1] : DUMMY_NODE;
  }

}

