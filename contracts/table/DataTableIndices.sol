pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './DataTableState.sol';
import './TableColumn.sol';
import './TableIndex.sol';

import '../common/StringUtils.sol';
import '../common/proxy/Controlled.sol';

contract DataTableIndices is DataTableState, Controlled {
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_DATA_TABLE_INDICES';
  string private constant ERR_DUPLICATED = 'DATA_DUPLICATED';
  string private constant ERR_INDEXED_COLUMN = 'CTR_INDEXED_COLUMN';
  string private constant ERR_NO_DATA = 'NO_DATA';

  constructor(address _controller) Controlled(_controller) public { }

  function addIndex(string memory _name, TableColumn memory _column) public {
    require((status == ST_AVAILABLE) || (status == ST_INITIALIZING), 'Status must be ST_AVAILABLE or ST_INITIALIZING');
    // Add index
    for (uint i = 0 ; i<Indices.length ; ++i) {
      // Check index name duplication
      require(StringUtils.notEquals(Indices[i].indexName, _name), ERR_DUPLICATED);
      // Check column duplication
      require(StringUtils.notEquals(Indices[i].columnName, _column.name), ERR_INDEXED_COLUMN);
    }
    address indexAddress = createModule(INDEX_FACTORY);
    Controlled controlled = Controlled(indexAddress);
    address comparator = controlled.getModule(COMPARATOR + _column.dataType);
    controlled.controller().setModule(COMPARATOR, comparator);
    TableIndex memory tableIndex = TableIndex({ indexName: _name, columnName: _column.name, addrezz: indexAddress });
    Indices.push(tableIndex);
  }

  function removeIndex(string memory _name) public {
    // Drop index
    uint deletionCount = 0;
    uint beforeIndices = Indices.length;
    require(StringUtils.notEquals(_name, name), 'Should not remove key index');
    for (uint i = 0 ; i<Indices.length ; ++i ) {
      uint index = uint(i - deletionCount);
      if (StringUtils.equals(Indices[index].indexName, _name)) {
        Indices[index] = Indices[Indices.length - 1];
        Indices.pop();
        ++deletionCount;
        --i;
      }
    }
    // Check if index deleted
    require(1 == deletionCount, ERR_NO_DATA);
    // Check if index size decreased
    require(beforeIndices - deletionCount == Indices.length, ERR_ILLEGAL);
  }

}