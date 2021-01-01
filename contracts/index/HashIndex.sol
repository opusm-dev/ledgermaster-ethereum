pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';
import './Index.sol';

contract HashIndex is Index {
  string private constant ERR_EMPTY_KEY = 'EMPTY_KEY';
  string[] keys;
  mapping (string => uint) key2sequence;
  mapping (string => string[]) key2values;
  mapping (string => uint) value2sequence;

  function add(string memory key, string memory value) public override {
    require(StringUtils.isNotEmpty(key), ERR_EMPTY_KEY);
    uint valueSeq = value2sequence[value];
    if (0 == valueSeq) {
      // insert
      key2values[key].push(value);
      value2sequence[value] = key2values[key].length;
      keys.push(key);
      key2sequence[key] = keys.length;
    } else {
      // update
      uint oldIndex = value2sequence[value];
      key2values[key][oldIndex] = value;
    }
  }

  function remove(string memory key, string memory value) public override {
    require(StringUtils.isNotEmpty(key), ERR_EMPTY_KEY);
    uint valueSequence = value2sequence[value];
    if (0 != valueSequence) {
      uint movingValueSequence = key2values[key].length;
      string memory movingValue = key2values[key][movingValueSequence - 1];
      key2values[key][valueSequence - 1] = movingValue;
      delete key2values[key][movingValueSequence - 1];
      value2sequence[movingValue] = valueSequence;
      if (movingValueSequence == 1) {
        uint keySequence = key2sequence[key];
        uint movingKeySequence = keys.length;
        string memory movingKey = keys[movingKeySequence - 1];
        keys[keySequence - 1] = movingKey;
        key2sequence[movingKey] = keySequence;
        delete keys[movingKeySequence - 1];
      }
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
    return key2values[start.value].length;
  }
}
