pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableColumn.sol';
import './TableRow.sol';
import '../common/ValuePoint.sol';

interface RowRepository {
  function size() external view returns (uint);
  function get(string calldata key) external view returns (TableRow memory);
  function get(string[] calldata keys, bool reverse) external view returns (TableRow[] memory);
  function set(string calldata key, TableRow calldata _row) external;
  function remove(string calldata key) external;
  function findBy(TableColumn calldata _column, ValuePoint calldata _start, ValuePoint calldata _end, int _orderType) external view returns (TableRow[] memory);
  function countBy(TableColumn calldata _column, ValuePoint calldata _start, ValuePoint calldata _end) external view returns (uint);
}