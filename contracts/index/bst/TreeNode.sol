pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

struct TreeNode {
  // 0x00: NotAvailable, 0x05: Right, 0x09: Left, 0x0d: Both, 0x01: Leaf
  bytes1 kind;
  string key;
  string[] values;
  string left;
  string right;
}
