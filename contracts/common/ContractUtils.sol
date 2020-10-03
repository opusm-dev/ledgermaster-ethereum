pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

library ContractUtils {
  function isContract(address _target) internal view returns (bool) {
    if (_target == address(0)) {
      return false;
    }

    uint256 size;
    assembly { size := extcodesize(_target) }
    return size > 0;
  }
}