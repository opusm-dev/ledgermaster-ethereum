pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './lib/tree.sol';

/**
 *
 */
interface NodeRepository {
  /* Node related */
  function create(string calldata key) external;
  function get(string calldata key) external view returns (tree.Node memory);
  function set(tree.Node calldata value) external;
  function remove(string calldata key) external;

  /* Value related */
  function add(string calldata key, string calldata value) external;
  function remove(string calldata key, string calldata value) external returns (int);

  function getRoot() external view returns (tree.Node memory);
  function setRoot(tree.Node calldata key) external;

  function left(tree.Node calldata _node) external view returns (tree.Node memory);
  function right(tree.Node calldata _node) external view returns (tree.Node memory);

  function details(tree.Node calldata _node) external view returns (tree.NodeDetails memory);
  function contains(string calldata _key, string calldata _value) external view returns (bool);
  function size() external view returns (uint);
  function find(uint _finder, string calldata _key) external view returns (tree.Node[] memory);
  function find(uint _finder, tree.Node calldata _node, string calldata _key) external view returns (tree.Node[] memory);
}
