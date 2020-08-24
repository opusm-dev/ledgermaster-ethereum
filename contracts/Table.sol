pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import './lib/tab.sol';

interface Table {
  struct TableMetadata {
    string name;
    string keyColumn;
    address location;
    table.Column[] columns;
    table.Index[] indices;
  }

  struct ColumnInput {
    string name;
    int dataType;
  }

  struct IndexInput {
    string indexName;
    string columnName;
  }

  struct ValuePoint {
    string value;
    /**
     * -1: Unbound
     * 0: Inclusion
     * 1: Exclusion
     */
    int boundType;
  }

  function initialize(address store, string calldata _name, ColumnInput calldata _keyColumn) external;
  function getStore() external returns (address);
  function setStatus(int status) external;
  function getMetadata() external view returns (TableMetadata memory);
}