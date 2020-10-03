pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

struct TableColumn {
  string name;
  /**
   * 1: string
   * 2: integer
   */
  uint dataType;
}
