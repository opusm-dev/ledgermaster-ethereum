pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';
import './Index.sol';

contract HashIndex is Index {
  string private constant ERR_EMPTY_KEY = 'EMPTY_KEY';
  mapping (string => string) value2key;
  mapping (string => uint) key2count;

  function add(string memory key, string memory value) public override {
    require(StringUtils.isNotEmpty(key), ERR_EMPTY_KEY);
    string memory oldKey = value2key[value];
    if (StringUtils.isNotEmpty(oldKey)) {
      // update
      key2count[oldKey]--;
    }
    value2key[value] = key;
    key2count[key]++;
  }

  function remove(string memory key, string memory value) public override {
    require(StringUtils.isNotEmpty(key), ERR_EMPTY_KEY);
    string memory oldKey = value2key[value];
    if (StringUtils.isNotEmpty(oldKey)) {
      delete value2key[value];
      key2count[oldKey]--;
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
