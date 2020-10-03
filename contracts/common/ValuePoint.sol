pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

struct ValuePoint {
  string value;
  /**
   * -1: Unbound
   * 0: Inclusion
   * 1: Exclusion
   */
  int boundType;
}
