pragma solidity ^0.6.4;

import "../common/ValuePoint.sol";
pragma experimental ABIEncoderV2;

interface Index {
  function add(string calldata _key, string calldata _value) external;
  function remove(string calldata _key, string calldata _value) external;
  function findBy(ValuePoint calldata start, ValuePoint calldata end) external view returns (string[] memory);
  function countBy(ValuePoint calldata _start, ValuePoint calldata _end) external view returns (uint);
}
