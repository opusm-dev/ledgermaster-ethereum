pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/ValuePoint.sol';
import './Index.sol';

contract HashIndex is Index {
  mapping (string => string) value2key;
  mapping (string => string[]) key2values;

  function add(string memory key, string memory value) public override {
  }

  function remove(string memory key, string memory value) public override {
  }

  function findBy(ValuePoint memory start, ValuePoint memory end) public view override returns (string[] memory) {
    require(start.boundType == 0 && end.boundType == 0, 'UNSUPPORTED_ARG');
    require(0 == strcmp(start.value, end.value), 'UNSUPPORTED_ARG');
    return new string[](0);
  }

  function countBy(ValuePoint memory start, ValuePoint memory end) public view override returns (uint) {
    require(start.boundType == 0 && end.boundType == 0, 'UNSUPPORTED_ARG');
    require(0 == strcmp(start.value, end.value), 'UNSUPPORTED_ARG');
    return 0;
  }

  function strcmp(string memory s1, string memory s2) public pure returns (int) {
    return 0;
  }
}
