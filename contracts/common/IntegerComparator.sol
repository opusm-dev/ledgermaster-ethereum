pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Comparator.sol';
import './IntegerUtils.sol';

contract IntegerComparator is Comparator {
  function compare(string memory v1, string memory v2) public override pure returns (int) {
    int i1 = IntegerUtils.parseInt(v1);
    int i2 = IntegerUtils.parseInt(v2);
    return (i1 == i2)?0:(i1 > i2)?int(1):-1;
  }

  function equals(string calldata v1, string calldata v2) external override pure returns (bool) {
    return 0 == compare(v1, v2);
  }

  function notEquals(string calldata v1, string calldata v2) external override pure returns (bool) {
    return 0 != compare(v1, v2);
  }


}
