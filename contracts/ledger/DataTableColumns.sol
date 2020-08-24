pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../lib/system.sol';
import '../lib/tab.sol';
import './DataTableState.sol';

contract DataTableColumns is DataTableState {
  /* General operations */
  string private constant ERR_ST_AVAILABLE = 'SHOULD_BE_AVAILABLE';
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_DATA_TABLE_COLUMNS';
  string private constant ERR_NO_DATA = 'NO_DATA';
  string private constant ERR_DUPLICATED = 'DATA_DUPLICATED';
  string private constant ERR_INDEXED_COLUMN = 'CTR_INDEXED_COLUMN';

  /*****************************/
  /* Column-related governance */
  /*****************************/
  function addColumn(string memory _name, int256 _type) public {
    require(status == ST_AVAILABLE || status == ST_INITIALIZING, 'Status must be ST_AVAILABLE or ST_INITIALIZING');
    require(validateColumn(_name, _type), 'Column is not valid');
    for (uint i = 0 ; i<Columns.length ; ++i) {
      // Check column name duplication
      require(utils.notEquals(Columns[i].name, _name), ERR_DUPLICATED);
    }
    table.Column memory column = table.Column({
      name: _name,
      dataType: _type
    });
    Columns.push(column);
  }

  function removeColumn(string memory _name) public {
    require(status == ST_AVAILABLE, ERR_ST_AVAILABLE);
    uint deletionCount = 0;
    uint beforeColumns = Columns.length;
    // 키 칼럼은 삭제할 수 없다.
    require(utils.notEquals(keyColumn, _name), 'Should not remove key column');
    // 인덱스가 있으면 삭제할 수 없다.
    for (uint i = 0 ; i<Indices.length ; ++i ) {
      require(utils.notEquals(Indices[i].columnName, _name), ERR_INDEXED_COLUMN);
    }
    for (uint i = 0 ; i < Columns.length ; ++i) {
      uint index = uint(i - deletionCount);
      if (utils.equals(Columns[index].name, _name)) {
        Columns[index] = Columns[Columns.length - 1];
        Columns.pop();
        ++deletionCount;
        --i;
      }
    }
    // Check if column deleted
    require(1 == deletionCount, ERR_NO_DATA);
    // Check if column size decreased
    require(beforeColumns - deletionCount == Columns.length, ERR_ILLEGAL);
  }

  function validateColumnName(string memory _name) internal pure returns (bool) {
    return utils.isNotEmpty(_name);
  }
  function validateColumn(string memory _name, int _type) internal pure returns (bool) {
    return ((_type == 1) || (_type == 2)) && validateColumnName(_name);
  }
}
