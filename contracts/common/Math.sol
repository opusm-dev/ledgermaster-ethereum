pragma solidity ^0.6.4;

library Math {
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
}
