pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableColumn.sol';
import './TableIndex.sol';
import './TableRow.sol';

contract DataTableState {
  address store;
  string name;
  address[] public Constraints;
  TableColumn[] public Columns;
  TableIndex[] Indices;
  string[] Keys;
}