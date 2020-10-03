pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Math.sol';

library StringUtils {
  function compare(string memory v1, string memory v2) internal pure returns (int) {
    bytes memory _v1 = bytes(v1);
    bytes memory _v2 = bytes(v2);
    uint length = Math.min(_v1.length, _v2.length);

    for(uint i=0; i<length ; i++) {
      if (_v1[i] < _v2[i]) {
        return -1;
      } else if (_v1[i] > _v2[i]) {
        return 1;
      }
    }
    return (_v1.length < _v2.length)?-1:(_v1.length > _v2.length)?int(1):int(0);
  }

  function equals(string memory v1, string memory v2) internal pure returns (bool) {
    return 0 == compare(v1, v2);
  }

  function notEquals(string memory v1, string memory v2) internal pure returns (bool) {
    return 0 != compare(v1, v2);
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

  function concat(string memory _str1, string memory _str2) internal pure returns (string memory) {
    bytes memory bstr1 = bytes(_str1);
    bytes memory bstr2 = bytes(_str2);
    string memory str = new string(bstr1.length + bstr2.length);
    bytes memory b = bytes(str);
    uint k = 0;
    for (uint i = 0; i < bstr1.length; i++) {
      b[k++] = bstr1[i];
    }
    for (uint i = 0; i < bstr2.length; i++) {
      b[k++] = bstr2[i];
    }
    return string(b);
  }
}
