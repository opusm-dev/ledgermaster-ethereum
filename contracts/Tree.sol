pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './NodeRepository.sol';

interface Tree {
  function getNodeRepository() external view returns (NodeRepository);
}