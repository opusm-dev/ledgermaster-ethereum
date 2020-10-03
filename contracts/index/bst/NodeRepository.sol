pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TreeNode.sol';
import './TreeNodeDetails.sol';
/**
 *
 */
interface NodeRepository {
  /* Node related */
  function create(string calldata key) external;
  function get(string calldata key) external view returns (TreeNode memory);
  function set(TreeNode calldata value) external;
  function remove(string calldata key) external;

  /* Value related */
  function add(string calldata key, string calldata value) external;
  function remove(string calldata key, string calldata value) external returns (int);

  function getRoot() external view returns (TreeNode memory);
  function setRoot(TreeNode calldata key) external;

  function left(TreeNode calldata _node) external view returns (TreeNode memory);
  function right(TreeNode calldata _node) external view returns (TreeNode memory);

  function details(TreeNode calldata _node) external view returns (TreeNodeDetails memory);
  function contains(string calldata _key, string calldata _value) external view returns (bool);
  function size() external view returns (uint);
  function find(uint _finder, string calldata _key) external view returns (TreeNode[] memory);
  function find(uint _finder, TreeNode calldata _node, string calldata _key) external view returns (TreeNode[] memory);
}
