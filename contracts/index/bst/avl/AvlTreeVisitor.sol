pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../NodeRepository.sol';
import '../TreeNodeStack.sol';
import '../TreeNodeUtils.sol';
import '../TreeVisitor.sol';

import '../../../common/Math.sol';
import '../../../common/Arrays.sol';
import '../../../common/ValuePointUtils.sol';
import '../../../common/proxy/Controlled.sol';

contract AvlTreeVisitor is TreeVisitor, Controlled {

  constructor(address _controller) Controlled(_controller) public { }

  /**
   * point type:
   * -1 - unbound
   * 0 - Included bound
   * 1 - Excluded bound
   */
  function findBy(NodeRepository repository, ValuePoint memory start, ValuePoint memory end) public view override returns (string[] memory) {
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    uint elementCount = countBy(repository, start, end);
    string[] memory target = new string[](elementCount);
    TreeNodeStack memory stack = calculateCandidate(repository, start, end);
    uint targetIndex = 0;
    // 데이터를 배열에 담기 위해 순회(iteration)한다.
    while (0 < stack.index) {
      TreeNode memory current = popNode(stack);
      if (TreeNodeUtils.hasRight(current)) {
        TreeNode memory iter = repository.get(current.right);
        pushAllLeftNode(repository, stack, iter);
      }
      if (ValuePointUtils.checkUpper(comparator, end, current.key)) {
        targetIndex += Arrays.arraycopy(current.values, 0, target, targetIndex, current.values.length);
      } else {
        stack.index = 0;
      }
    }
    return target;
  }

  function countBy(NodeRepository repository, ValuePoint memory start, ValuePoint memory end) public view override returns (uint) {
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    TreeNodeStack memory stack = calculateCandidate(repository, start, end);
    // 몇개의 응답이 필요한지 계산한다.
    uint elementCount = 0;
    // 몇개의 응답이 필요한지 계산하기 위해서 순회(iteration)한다.
    while (0 < stack.index) {
      // Pop
      TreeNode memory current = popNode(stack);
      if (TreeNodeUtils.hasRight(current)) {
        TreeNode memory iter = repository.get(current.right);
        pushAllLeftNode(repository, stack, iter);
      }
      if (ValuePointUtils.checkUpper(comparator, end, current.key)) {
        elementCount += current.values.length;
      } else {
        stack.index = 0;
      }
    }
    return elementCount;
  }


  function calculateCandidate(NodeRepository repository, ValuePoint memory start, ValuePoint memory end) public view returns (TreeNodeStack memory) {
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    uint finder;
    if (-1 == start.boundType) {
      finder = MIN_FINDER;
    } else {
      finder = NODE_FINDER;
    }
    TreeNode[] memory path = repository.find(finder, start.value);
    uint cap = Math.max(2 * path.length, 10);
    TreeNodeStack memory stack = TreeNodeStack({
      capacity: cap,
      elements: new TreeNode[](cap),
      index: 0
      });

    for (uint i=0 ; i<path.length ; ++i) {
      ValuePoint memory _start = ValuePoint({
        value: start.value,
        boundType: (start.boundType==-1)?-1:int(0)
      });
      ValuePoint memory _end = ValuePoint({
      value: end.value,
      boundType: (end.boundType==-1)?-1:int(0)
      });
    if (ValuePointUtils.checkBound(comparator, _start, _end, path[i].key)) {
        // Push
        pushNode(stack, path[i]);
      }
    }
    if ((start.boundType==1) && (0<stack.index)) {
      TreeNode memory last = popNode(stack);
      if (comparator.equals(start.value, last.key)) {
        if (TreeNodeUtils.hasRight(last)) {
          pushAllLeftNode(repository, stack, repository.right(last));
        }
      }
    }
    return stack;
  }

  function popNode(TreeNodeStack memory _stack) internal pure returns (TreeNode memory) {
    return _stack.elements[--_stack.index];
  }
  function pushNode(TreeNodeStack memory _stack, TreeNode memory _node) internal pure {
    _stack.elements[_stack.index++] = _node;
  }
  function pushAllLeftNode(NodeRepository repository, TreeNodeStack memory _stack, TreeNode memory _node) internal view {
    pushNode(_stack, _node);
    if (TreeNodeUtils.hasLeft(_node)) {
      pushAllLeftNode(repository, _stack, repository.get(_node.left));
    }
  }
}