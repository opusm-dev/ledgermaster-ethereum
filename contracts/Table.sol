pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import "./lib/tab.sol";

interface Table {
  function initialize(address store, string calldata _name, string calldata _keyColumn, int _keyColumnType) external;
  function getStore() external returns (address);
  function setStatus(int status) external;
  function getMetadata() external view returns (table.TableMetadata memory);
}