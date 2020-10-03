pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TreeNode.sol';

struct TreeNodeStack {
  uint capacity;
  uint index;
  TreeNode[] elements;
}
