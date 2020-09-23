pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

interface Index {
  function add(string calldata _key, string calldata _value) external;
  function remove(string calldata _key, string calldata _value) external;
  function findBy(string calldata start, int startType, string calldata end, int endType) external view returns (string[] memory);
  function countBy(string calldata _start, int _st, string calldata _end, int _et) external view returns (uint);
}
