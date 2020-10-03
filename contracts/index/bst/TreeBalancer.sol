pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './NodeRepository.sol';

interface TreeBalancer {
  function balance(NodeRepository repository) external;
}