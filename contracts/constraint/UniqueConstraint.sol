pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';

import '../table/Constraint.sol';
import '../table/Table.sol';
import '../table/TableRow.sol';

contract UniqueConstraint is Constraint {
  string uniqueColumn;
  constructor(string memory column) public {
    uniqueColumn = column;
  }
  function checkInsert(address sender, address, TableRow memory row) public view override returns (bool) {
    Table table = Table(sender);
    ValuePoint memory vp = ValuePoint({
      value: getValue(row, uniqueColumn),
      boundType: 0
    });
    TableRow[] memory rows = table.findBy(uniqueColumn, vp, vp, 0);
    return rows.length == 0;
  }

  function checkDelete(address, address, TableRow memory) public view override returns (bool) {
    return true;
  }

  function checkUpdate(address sender, address, TableRow memory, TableRow memory newRow) public override view returns (bool) {
    Table table = Table(sender);
    ValuePoint memory vp = ValuePoint({
      value: getValue(newRow, uniqueColumn),
      boundType: 0
    });
    TableRow[] memory rows = table.findBy(uniqueColumn, vp, vp, 0);
    return rows.length == 0;
  }

  function getValue(TableRow memory row, string memory columnName) private pure returns (string memory) {
    for (uint i = 0 ; i < row.names.length ; ++i) {
      if (StringUtils.equals(row.names[i], columnName)) {
        return row.values[i];
      }
    }
    return '';
  }
}
