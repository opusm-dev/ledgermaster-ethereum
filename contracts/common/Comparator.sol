pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

interface Comparator {
  function compare(string calldata v1, string calldata v2) external pure returns (int);
  function equals(string calldata v1, string calldata v2) external pure returns (bool);
  function notEquals(string calldata v1, string calldata v2) external pure returns (bool);
}
