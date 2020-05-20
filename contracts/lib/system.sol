pragma solidity ^0.6.4;

library utils {
  function isContract(address _target) internal view returns (bool) {
    if (_target == address(0)) {
      return false;
    }

    uint256 size;
    assembly { size := extcodesize(_target) }
    return size > 0;
  }

  function min(int a, int b) internal pure returns (int) {
    if (a<b) {
      return a;
    } else {
      return b;
    }
  }
  function max(int a, int b) internal pure returns (int) {
    if (a>b) {
      return a;
    } else {
      return b;
    }
  }

  function min(uint a, uint b) internal pure returns (uint) {
    if (a<b) {
      return a;
    } else {
      return b;
    }
  }
  function max(uint a, uint b) internal pure returns (uint) {
    if (a>b) {
      return a;
    } else {
      return b;
    }
  }

  function compare(string memory _a, string memory _b) internal pure returns (int) {
    bytes memory a = bytes(_a);
    bytes memory b = bytes(_b);
    uint length = min(a.length, b.length);

    for(uint i=0; i<length; i++) {
      if (a[i] < b[i]) {
        return -1;
      } else if (a[i] > b[i]) {
        return 1;
      }
    }
    return int(a.length) - int(b.length);
  }

  function length(string memory str) internal pure returns (uint) {
    return bytes(str).length;
  }

  function isEmpty(string memory str) internal pure returns (bool) {
    return length(str) == 0;
  }

  function isNotEmpty(string memory str) internal pure returns (bool) {
    return !isEmpty(str);
  }

  function equals(string memory _a, string memory _b) internal pure returns (bool) {
    return 0 == compare(_a, _b);
  }

  function notEquals(string memory _a, string memory _b) internal pure returns (bool) {
    return 0 != compare(_a, _b);
  }

  function arraycopy(string[] memory _src, uint _srcPos, string[] memory _dest, uint _destPos, uint _length) internal pure returns (uint) {
    for (uint i=0 ; i<_length ; ++i) {
      _dest[_destPos + i] = _src[_srcPos + i];
    }
    return _length;
  }

  function checkLower(string memory _lowerValue, int _lowerType, string memory _value) internal pure returns (bool) {
    if (-1 == _lowerType) {
      // Unbound
      return true;
    } else {
      int comparison = compare(_lowerValue, _value);
      return (comparison < 0) || (_lowerType == 0 && comparison == 0);
    }
  }

  function checkUpper(string memory _upperValue, int _upperType, string memory _value) internal pure returns (bool) {
    if (-1 == _upperType) {
      // Unbound
      return true;
    } else {
      int comparison = compare(_value, _upperValue);
      return (comparison < 0) || (_upperType == 0 && comparison == 0);
    }
  }

  function checkBound(string memory _lowerValue, int _lowerType, string memory _upperValue, int _upperType, string memory _value) internal pure returns (bool) {
    return checkLower(_lowerValue, _lowerType, _value) && checkUpper(_upperValue, _upperType, _value);
  }
}
