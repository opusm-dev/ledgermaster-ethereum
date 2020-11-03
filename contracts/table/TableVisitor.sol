pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableRow.sol';
import './Table.sol';

import '../common/ValuePoint.sol';

interface TableVisitor {
  function findBy(Table table, uint columnIndex, ValuePoint calldata _start, ValuePoint calldata _end, int _orderType) external view returns (TableRow[] memory);
  function countBy(Table table, uint columnIndex, ValuePoint calldata _start, ValuePoint calldata _end) external view returns (uint);
}