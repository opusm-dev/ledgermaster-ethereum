pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Utilities */
import './system.sol';

library tree {
  struct Node {
    // 0: NotAvailable, 1: Right, 2: Left, 3: Both, 4: Leaf
    bytes1 kind;
    string key;
    string[] values;
    string left;
    string right;
  }

  struct NodeDetails {
    string key;
    bool isBalanced;
    int height;
    int bf;
    bool isLeftBalanced;
    int leftHeight;
    bool isRightBalanced;
    int rightHeight;
  }

  struct NodeStack {
    uint capacity;
    uint index;
    Node[] elements;
  }

  function isAvailable(Node memory node) internal pure returns (bool) {
    return (node.kind & 0x01) != 0x00;
  }
  function hasLeft(Node memory node) internal pure returns (bool) {
    return (node.kind & 0x08) != 0x00;
  }

  function unlinkLeft(Node memory node) internal pure returns (Node memory) {
    node.left = '';
    node.kind = node.kind & 0x07;
    return node;
  }

  function linkLeft(Node memory node, string memory left) internal pure returns (Node memory) {
    node.left = left;
    node.kind = node.kind | 0x08;
    return node;
  }

  function hasRight(Node memory node) internal pure returns (bool) {
    return (node.kind & 0x04) != 0x00;
  }

  function unlinkRight(Node memory node) internal pure returns (Node memory) {
    node.right = '';
    node.kind = node.kind & 0x0b;
    return node;
  }

  function linkRight(Node memory node, string memory right) internal pure returns (Node memory) {
    node.right = right;
    node.kind = node.kind | 0x04;
    return node;
  }

}
