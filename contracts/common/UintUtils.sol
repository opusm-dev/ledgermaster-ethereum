pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

library UintUtils {
  function toString(uint _i) internal pure returns (string memory) {
    if (_i == 0) {
      return '0';
    }
    uint j = _i;
    uint len = 0;
    while (j != 0) {
      ++len;
      j /= 10;
    }
    bytes memory byteValues = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      byteValues[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(byteValues);
  }
}