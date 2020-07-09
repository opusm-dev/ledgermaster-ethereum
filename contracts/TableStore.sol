pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

interface TableStore {
  function registerTable(address _address) external;
  function deregisterTable(string calldata _name) external;
  function listTableNames() external view returns (string[] memory);
  function getTable(string calldata _tableName) external view returns (address);
}