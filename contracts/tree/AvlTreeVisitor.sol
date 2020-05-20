pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "../Visitor.sol";
import "../NodeRepository.sol";
import "../proxy/Modules.sol";

contract AvlTreeVisitor is Visitor, Modules {
  /**
   * point type:
   * -1 - unbound
   * 0 - Included bound
   * 1 - Excluded bound
   */
  function findBy(
    NodeRepository repository,
    string memory start,
    int startType,
    string memory end,
    int endType) public view override returns (string[] memory) {
    uint elementCount = countBy(repository, start, startType, end, endType);
    string[] memory target = new string[](elementCount);
    tree.NodeStack memory stack = calculateCandidate(repository, start, startType, end, endType);
    uint targetIndex = 0;
    // 데이터를 배열에 담기 위해 순회(iteration)한다.
    while (0 < stack.index) {
      tree.Node memory current = popNode(stack);
      if (tree.hasRight(current)) {
        tree.Node memory iter = repository.get(current.right);
        pushAllLeftNode(repository, stack, iter);
      }
      if (utils.checkUpper(end, endType, current.key)) {
        targetIndex += utils.arraycopy(current.values, 0, target, targetIndex, current.values.length);
      } else {
        stack.index = 0;
      }
    }
    return target;
  }

  function countBy(
    NodeRepository repository,
    string memory start,
    int startType,
    string memory end,
    int endType) public view override returns (uint) {
    tree.NodeStack memory stack = calculateCandidate(repository, start, startType, end, endType);
    // 몇개의 응답이 필요한지 계산한다.
    uint elementCount = 0;
    // 몇개의 응답이 필요한지 계산하기 위해서 순회(iteration)한다.
    while (0 < stack.index) {
      // Pop
      tree.Node memory current = popNode(stack);
      if (tree.hasRight(current)) {
        tree.Node memory iter = repository.get(current.right);
        pushAllLeftNode(repository, stack, iter);
      }
      if (utils.checkUpper(end, endType, current.key)) {
        elementCount += current.values.length;
      } else {
        stack.index = 0;
      }
    }
    return elementCount;
  }


  function calculateCandidate(
    NodeRepository repository,
    string memory start,
    int startType,
    string memory end,
    int endType)
  public view
  returns (tree.NodeStack memory) {

    uint finder;
    if (-1 == startType) {
      finder = MIN_FINDER;
    } else {
      finder = NODE_FINDER;
    }
    tree.Node[] memory path = repository.find(finder, start);
    uint cap = utils.max(2 * path.length, 10);
    tree.NodeStack memory stack = tree.NodeStack({
      capacity: cap,
      elements: new tree.Node[](cap),
      index: 0
      });

    for (uint i=0 ; i<path.length ; ++i) {
      if (utils.checkBound(start, (startType==-1)?-1:int(0), end, (endType==-1)?-1:int(0), path[i].key)) {
        // Push
        pushNode(stack, path[i]);
      }
    }
    if ((startType==1) && (0<stack.index)) {
      tree.Node memory last = popNode(stack);
      if (utils.equals(start, last.key)) {
        if (tree.hasRight(last)) {
          pushAllLeftNode(repository, stack, repository.right(last));
        }
      }
    }
    return stack;
  }

  function popNode(tree.NodeStack memory _stack) internal pure returns (tree.Node memory) {
    return _stack.elements[--_stack.index];
  }
  function pushNode(tree.NodeStack memory _stack, tree.Node memory _node) internal pure {
    _stack.elements[_stack.index++] = _node;
  }
  function pushAllLeftNode(NodeRepository repository, tree.NodeStack memory _stack, tree.Node memory _node) internal view {
    pushNode(_stack, _node);
    if (tree.hasLeft(_node)) {
      pushAllLeftNode(repository, _stack, repository.get(_node.left));
    }
  }
}