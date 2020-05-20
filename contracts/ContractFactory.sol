pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

interface ContractFactory {
  function create(string calldata key) external;
  function get(string calldata key) external view returns (address);
}
