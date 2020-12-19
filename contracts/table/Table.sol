pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/ValuePoint.sol';

/* Utilities */
import './TableColumn.sol';
import './TableIndex.sol';
import './TableMetadata.sol';

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
  function size() external view returns (uint);
  function getStore() external returns (address);
  function getMetadata() external view returns (TableMetadata memory);
  function listRow(string[] calldata keys, bool reverse) external view returns (string[][] memory);
  function getRow(string calldata key) external view returns (string[] memory);
  function findBy(string calldata _column, ValuePoint calldata _start, ValuePoint calldata _end, int _orderType) external view returns (string[][] memory);
  function findRowsBy(TableColumn calldata _column, ValuePoint calldata _start, ValuePoint calldata _end, int _orderType) external view returns (string[][] memory);
  function countRowsBy(TableColumn calldata _column, ValuePoint calldata _start, ValuePoint calldata _end) external view returns (uint);
}