pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "./lib/tree.sol";
import "./NodeRepository.sol";

interface PathFinder {
  /**
   * Return value
   * r[0] = Root
   * r[1] = level1
   * r[2] = level2
   */
  function find(NodeRepository _repository, string calldata extra) external view returns (tree.Node[] memory);
  function find(NodeRepository _repository, tree.Node calldata _node, string calldata extra) external view returns (tree.Node[] memory);
}
