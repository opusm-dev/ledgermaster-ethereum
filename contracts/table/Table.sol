pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

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
  function getStore() external returns (address);
  function setStatus(int status) external;
  function getMetadata() external view returns (TableMetadata memory);
}