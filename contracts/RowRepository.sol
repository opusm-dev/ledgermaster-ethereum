pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "./lib/tab.sol";

interface RowRepository {
  function get(string calldata key) external view returns (table.Row memory);
  function get(string[] calldata keys, bool reverse) external view returns (table.Row[] memory);
  function set(string calldata key, table.Row calldata _row) external;
  function remove(string calldata key) external;
  function findBy(string calldata _column, string calldata _start, int _st, string calldata _end, int _et, int _orderType)
  external view returns (table.Row[] memory);
}