pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';

import '../table/Constraint.sol';
import '../table/Table.sol';
import '../table/TableRow.sol';

contract UniqueConstraint is Constraint {
  uint uniqueColumnIndex;
  constructor(uint index) public {
    uniqueColumnIndex = index;
  }
  function checkInsert(address sender, address, TableRow memory row) public view override returns (bool) {
    Table table = Table(sender);
    ValuePoint memory vp = ValuePoint({
      value: row.values[uniqueColumnIndex],
      boundType: 0
    });
    string memory uniqueColumnName = table.getMetadata().columns[uniqueColumnIndex].name;
    TableRow[] memory rows = table.findBy(uniqueColumnName, vp, vp, 0);
    return rows.length == 0;
  }

  function checkDelete(address, address, TableRow memory) public view override returns (bool) {
    return true;
  }

  function checkUpdate(address sender, address, TableRow memory, TableRow memory newRow) public override view returns (bool) {
    Table table = Table(sender);
    ValuePoint memory vp = ValuePoint({
      value: newRow.values[uniqueColumnIndex],
      boundType: 0
    });
    string memory uniqueColumnName = table.getMetadata().columns[uniqueColumnIndex].name;
    TableRow[] memory rows = table.findBy(uniqueColumnName, vp, vp, 0);
    return rows.length == 0;
  }
}
