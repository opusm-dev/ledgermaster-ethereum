pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableColumn.sol';
import './TableIndex.sol';
import './TableRow.sol';

contract DataTableState {
  int constant ST_CREATED = -1;
  int constant ST_AVAILABLE = 0;
  int constant ST_INITIALIZING = 1;
  int constant ST_TEMPORARY_UNAVAILABLE = 2;

  int public status = ST_CREATED;
  struct RowNode2 {
    TableRow row;
    uint index;
    bool available;
  }

  address store;
  string name;
  address[] public Constraints;
  TableColumn[] public Columns;
  TableIndex[] Indices;
  string[] Keys;
  mapping(string => RowNode2) public Rows;

}