pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

library IntegerUtils {
  function parseInt(string memory str) internal pure returns (int) {
    int answer = 0;
    bytes memory bs = bytes(str);
    require(0 < bs.length, 'NaN');
    int sign = (byte('-') == bs[0])?-1:int(1);
    uint start = (byte('-') == bs[0])?1:0;
    for(uint i=start ; i<bs.length ; i++) {
      require((48 <= uint8(bs[i])) && (uint8(bs[i]) <= 57), 'NaN');
      answer = 10 * answer + (uint8(bs[i]) - 48);
    }
    return sign * answer;
  }
}
