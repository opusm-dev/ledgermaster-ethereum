pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import "./NodeRepository.sol";

interface Balancer {
  function balance(NodeRepository repository) external;
}