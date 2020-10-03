pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

struct TreeNodeDetails {
  string key;
  bool isBalanced;
  int height;
  int bf;
  bool isLeftBalanced;
  int leftHeight;
  bool isRightBalanced;
  int rightHeight;
}
