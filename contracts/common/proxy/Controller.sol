pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Controlled.sol';
import './ContractFactory.sol';

interface Controller {
  function createModule(address parent, uint _id) external returns (address);
  function createModule(uint _id) external returns (address);
  function getModule(uint _id) external view returns (address);
  function setModule(uint _id, address _address) external;
}
