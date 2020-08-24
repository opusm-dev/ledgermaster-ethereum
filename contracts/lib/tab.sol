pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './system.sol';

library table {
  struct Column {
    string name;
    /**
     * 1: string
     */
    int dataType;
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

}
