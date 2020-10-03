pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TreeNode.sol';
import './TreeNodeUtils.sol';
import './PathFinder.sol';
import './NodeRepository.sol';

contract MinimumFinder is PathFinder {
  function find(NodeRepository _repository, Comparator _comparator, string memory extra) public view override returns (TreeNode[] memory) {
    return find(_repository, _comparator, _repository.getRoot(), extra);
  }
  function find(NodeRepository _repository, Comparator _comparator, TreeNode memory _node, string memory extra) public view override returns (TreeNode[] memory) {
    if (TreeNodeUtils.isAvailable(_node)) {
      TreeNode[] memory path = find(_repository, _comparator, _repository.left(_node), extra);
      TreeNode[] memory newPath = new TreeNode[](path.length + 1);
      for (uint i=0 ; i<path.length ; ++i) {
        newPath[i + 1] = path[i];
      }
      newPath[0] = _node;
      return newPath;
    } else {
      return new TreeNode[](0);
    }
  }
}
