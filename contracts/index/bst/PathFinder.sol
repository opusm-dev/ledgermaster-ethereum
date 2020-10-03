pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './NodeRepository.sol';
import './TreeNode.sol';
import '../../common/Comparator.sol';

interface PathFinder {
  /**
   * Return value
   * r[0] = Root
   * r[1] = level1
   * r[2] = level2
   */
  function find(NodeRepository _repository, Comparator _comparator, string calldata extra) external view returns (TreeNode[] memory);
  function find(NodeRepository _repository, Comparator _comparator, TreeNode calldata _node, string calldata extra) external view returns (TreeNode[] memory);
}
