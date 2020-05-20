pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import "./lib/tab.sol";

interface Table {
  function initialize(string calldata _name, string calldata _keyColumn, int _keyColumnType) external;
  function setStatus(int status) external;
  function getMetadata() external view returns (table.TableMetadata memory);
}