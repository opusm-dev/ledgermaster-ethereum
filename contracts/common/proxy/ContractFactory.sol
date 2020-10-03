pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

interface ContractFactory {
  function create(address _controller, address owner) external returns (address);
}
