pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Comparator.sol';
import './StringUtils.sol';

contract StringComparator is Comparator {
  function compare(string memory v1, string memory v2) public override pure returns (int) {
    return StringUtils.compare(v1, v2);
  }

  function equals(string calldata v1, string calldata v2) external override pure returns (bool) {
    return 0 == compare(v1, v2);
  }

  function notEquals(string calldata v1, string calldata v2) external override pure returns (bool) {
    return 0 != compare(v1, v2);
  }
}
