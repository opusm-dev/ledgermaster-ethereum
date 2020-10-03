pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './NodeRepository.sol';

interface NodeManager {
  function add(NodeRepository repository, string calldata _key, string calldata _value) external;
  function remove(NodeRepository repository, string calldata _key, string calldata _value) external;
}

