pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "./NodeRepository.sol";

interface Visitor {
  function findBy(NodeRepository repository, string calldata start, int startType, string calldata end, int endType) external view returns (string[] memory);
  function countBy(NodeRepository repository, string calldata start, int startType, string calldata end, int endType) external view returns (uint);
}
