pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TreeNode.sol';

library TreeNodeUtils {

  function isAvailable(TreeNode memory node) internal pure returns (bool) {
    return (node.kind & 0x01) != 0x00;
  }
  function hasLeft(TreeNode memory node) internal pure returns (bool) {
    return (node.kind & 0x08) != 0x00;
  }

  function unlinkLeft(TreeNode memory node) internal pure returns (TreeNode memory) {
    node.left = '';
    node.kind = node.kind & 0x07;
    return node;
  }

  function linkLeft(TreeNode memory node, string memory left) internal pure returns (TreeNode memory) {
    node.left = left;
    node.kind = node.kind | 0x08;
    return node;
  }

  function hasRight(TreeNode memory node) internal pure returns (bool) {
    return (node.kind & 0x04) != 0x00;
  }

  function unlinkRight(TreeNode memory node) internal pure returns (TreeNode memory) {
    node.right = '';
    node.kind = node.kind & 0x0b;
    return node;
  }

  function linkRight(TreeNode memory node, string memory right) internal pure returns (TreeNode memory) {
    node.right = right;
    node.kind = node.kind | 0x04;
    return node;
  }

}
