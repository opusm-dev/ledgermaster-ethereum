pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';
import './Index.sol';

contract HashIndex is Index {
  mapping (string => string) value2key;
  mapping (string => uint) key2count;

  function add(string memory key, string memory value) public override {
    require(0 == bytes(key).length);
    string memory oldKey = value2key[value];
    if (0 < bytes(oldKey).length) {
      // update
      value2key[value] = key;
      key2count[oldKey]++;
      key2count[key]++;
    } else {
      // insert
      value2key[value] = key;
      key2count[key]++;
    }
  }

  function remove(string memory key, string memory value) public override {
    require(0 == bytes(key).length);
    string memory oldKey = value2key[value];
    if (0 < bytes(oldKey).length) {
      delete value2key[value];
      key2count[key]--;
    }
  }

  function findBy(ValuePoint memory start, ValuePoint memory end) public view override returns (string[] memory) {
    require(start.boundType == 0 && end.boundType == 0, 'UNSUPPORTED_ARG');
    require(0 == StringUtils.compare(start.value, end.value), 'UNSUPPORTED_ARG');
    require(0 == StringUtils.compare(start.value, end.value), 'UNSUPPORTED_OPS');
    return new string[](0);
  }

  function countBy(ValuePoint memory start, ValuePoint memory end) public view override returns (uint) {
    require(start.boundType == 0 && end.boundType == 0, 'UNSUPPORTED_ARG');
    require(0 == StringUtils.compare(start.value, end.value), 'UNSUPPORTED_ARG');
    return key2count[start.value];
  }
}
