pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/ValuePoint.sol';

/* Utilities */
import './TableColumn.sol';
import './TableIndex.sol';
import './TableMetadata.sol';
import './TableRow.sol';

interface Table {
  struct ColumnInput {
    string name;
    uint dataType;
  }

  struct IndexInput {
    string indexName;
    string columnName;
  }

  function initialize(address store, string calldata _name, string calldata _keyColumnName, uint _keyColumnType) external;
  function getStore() external returns (address);
  function getMetadata() external view returns (TableMetadata memory);
  function getRow(string calldata key) external view returns (string[] memory);
  function findBy(string calldata _column, ValuePoint calldata _start, ValuePoint calldata _end, int _orderType) external view returns (TableRow[] memory);
}