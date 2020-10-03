pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

library Arrays {
  function arraycopy(string[] memory _src, uint _srcPos, string[] memory _dest, uint _destPos, uint _length) internal pure returns (uint) {
    for (uint i=0 ; i<_length ; ++i) {
      _dest[_destPos + i] = _src[_srcPos + i];
    }
    return _length;
  }
}