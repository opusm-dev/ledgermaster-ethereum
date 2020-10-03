pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './ValuePoint.sol';
import './Comparator.sol';

library ValuePointUtils {
  function checkLower(Comparator comparator, ValuePoint memory _lower, string memory _value) internal pure returns (bool) {
    if (-1 == _lower.boundType) {
      // Unbound
      return true;
    } else {
      int comparison = comparator.compare(_lower.value, _value);
      return (comparison < 0) || (_lower.boundType == 0 && comparison == 0);
    }
  }

  function checkUpper(Comparator comparator, ValuePoint memory _upper, string memory _value) internal pure returns (bool) {
    if (-1 == _upper.boundType) {
      // Unbound
      return true;
    } else {
      int comparison = comparator.compare(_value, _upper.value);
      return (comparison < 0) || (_upper.boundType == 0 && comparison == 0);
    }
  }

  function checkBound(Comparator comparator, ValuePoint memory _lower, ValuePoint memory _upper, string memory _value) internal pure returns (bool) {
    return checkLower(comparator, _lower, _value) && checkUpper(comparator, _upper, _value);
  }

  function checkPoint(Comparator comparator, ValuePoint memory _lower, ValuePoint memory _upper) internal pure returns (bool) {
    return 0 == _lower.boundType && 0 == _upper.boundType && comparator.equals(_upper.value, _lower.value);
  }
}
