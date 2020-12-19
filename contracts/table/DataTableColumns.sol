pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './DataTableState.sol';
import './TableColumn.sol';

import '../common/StringUtils.sol';
import '../common/proxy/Controlled.sol';

contract DataTableColumns is DataTableState, Controlled {
  /* General operations */
  string private constant ERR_ST_AVAILABLE = 'SHOULD_BE_AVAILABLE';
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_DATA_TABLE_COLUMNS';
  string private constant ERR_NO_DATA = 'NO_DATA';
  string private constant ERR_DUPLICATED = 'DATA_DUPLICATED';
  string private constant ERR_INDEXED_COLUMN = 'CTR_INDEXED_COLUMN';

  constructor(address _controller) Controlled(_controller) public { }

  /*****************************/
  /* Column-related governance */
  /*****************************/
  function addColumn(string memory _name, uint _type) public {
    require(validateColumn(_name, _type), 'Column is not valid');
    for (uint i = 0 ; i<Columns.length ; ++i) {
      // Check column name duplication
      require(StringUtils.notEquals(Columns[i].name, _name), ERR_DUPLICATED);
    }
    TableColumn memory column = TableColumn({
      index: Columns.length,
      name: _name,
      dataType: _type
    });
    Columns.push(column);
  }

  function validateColumnName(string memory _name) internal pure returns (bool) {
    return StringUtils.isNotEmpty(_name);
  }
  function validateColumn(string memory _name, uint _type) internal pure returns (bool) {
    return ((_type == 1) || (_type == 2)) && validateColumnName(_name);
  }
}
