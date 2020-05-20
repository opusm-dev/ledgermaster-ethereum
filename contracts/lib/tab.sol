pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "./system.sol";

library table {
  struct TableMetadata {
    string name;
    string keyColumn;
    address location;
    Column[] columns;
    Index[] indices;
  }
  struct Column {
    string columnName;
    /**
     * 1: string
     * 2: numeric
     */
    int columnType;
  }

  struct Index {
    string indexName;
    string columnName;
    address addrezz;
  }

  struct Row {
    string[] names;
    string[] values;
    bool available;
  }

  function validateColumnName(string memory _name) internal pure returns (bool) {
    return utils.isNotEmpty(_name);
  }
  function validateColumn(string memory _name, int _type) internal pure returns (bool) {
    return ((_type == 1) || (_type == 2)) && validateColumnName(_name);
  }
}
