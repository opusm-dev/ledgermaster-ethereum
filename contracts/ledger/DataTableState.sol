pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../lib/tab.sol';

contract DataTableState {
  int constant ST_CREATED = -1;
  int constant ST_AVAILABLE = 0;
  int constant ST_INITIALIZING = 1;
  int constant ST_TEMPORARY_UNAVAILABLE = 2;

  int public status = ST_CREATED;

  address store;
  string name;
  string keyColumn;
  address[] public Constraints;
  table.Column[] public Columns;
  table.Index[] Indices;
}