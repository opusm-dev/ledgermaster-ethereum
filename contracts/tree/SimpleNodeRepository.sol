pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Interfaces */
import "../proxy/Controlled.sol";
import "../proxy/Controller.sol";
import "../NodeRepository.sol";

import "../proxy/Modules.sol";

/* Utilities */
import "../lib/system.sol";
import "../lib/tree.sol";

contract SimpleNodeRepository is NodeRepository, Controlled, Controller, Modules
{
  tree.Node DUMMY_NODE = tree.Node({
    kind: 0,
    key: '',
    values: new string[](0),
    left: '',
    right: ''
    });

  mapping(string => tree.Node) private nodes;
  tree.Node private _root = tree.Node({
    kind: bytes1(0x00),
    key: '',
    values: new string[](0),
    left: '',
    right: ''
  });

  event RootUpdated(tree.Node node);
  event NodeAdded(tree.Node node);
  event NodeRemoved(string key);
  event NodeUpdated(tree.Node node);
  event ValueAdded(string key, string value);
  event ValueRemoved(string key, string value, int n);

  function create(string memory _key) public override {
    tree.Node memory newNode = tree.Node({
      kind: bytes1(0x01),
      key: _key,
      values: new string[](0),
      left: '',
      right: ''
    });
    nodes[_key] = newNode;
    emit NodeAdded(newNode);
  }

  function get(string memory _key) public view override returns (tree.Node memory) {
    tree.Node memory node = nodes[_key];
    return node;
  }

  function remove(string memory _key) public override {
    delete nodes[_key] ;
    emit NodeRemoved(_key);
  }

  function set(tree.Node memory _node) public override {
    nodes[_node.key] = _node;
    emit NodeUpdated(_node);
  }

  function add(string memory _key, string memory _value) public override {
    nodes[_key].values.push(_value);
    emit ValueAdded(_key, _value);
  }

  function remove(string memory _key, string memory _value) public override returns (int) {
    tree.Node storage node = nodes[_key];
    if (!tree.isAvailable(node)) {
      return -1;
    }
    uint deletionCount = 0;
    for (uint i = 0 ; i < node.values.length ; ++i) {
      if (utils.equals(node.values[i], _value)) {
        uint source = node.values.length - deletionCount - 1;
        if (i != source) {
          node.values[i] = node.values[source];
        }
        node.values.pop();
        --i;
        ++deletionCount;
      }
    }
    int r = (0 < deletionCount)?int(node.values.length):-1;
    emit ValueRemoved(_key, _value, r);
    return r;
  }

  function getRoot() public override view returns (tree.Node memory) {
    if (tree.isAvailable(_root)) {
      return nodes[_root.key];
    } else {
      return _root;
    }
  }

  function setRoot(tree.Node memory _node) public override {
    _root = _node;
    emit RootUpdated(_node);
  }

  function contains(string memory _key, string memory _value)
    public view override
    returns (bool) {
    tree.Node memory node = get(_key);
    if (tree.isAvailable(node)) {
      if (utils.equals(node.key, _key)) {
        for (uint i=0 ; i<node.values.length ; i++) {
          if (utils.equals(node.values[i], _value)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  function size() public override view returns (uint) {
    return size(getRoot());
  }
  function size(tree.Node memory _node) public view returns (uint) {
    uint s = 0;
    if (tree.isAvailable(_node)) {
      s = _node.values.length;
      if (tree.hasLeft(_node)) {
        s += size(get(_node.left));
      }
      if (tree.hasRight(_node)) {
        s += size(get(_node.right));
      }
    }
    return s;
  }

  function find(uint _finder, string memory _key)
    public view override
    returns (tree.Node[] memory) {
    return PathFinder(getModule(_finder)).find(this, _key);
  }

  function find(uint _finder, tree.Node memory _node, string memory _key)
  public view override
  returns (tree.Node[] memory) {
    return PathFinder(getModule(_finder)).find(this, _node, _key);
  }


  function details(tree.Node memory _node)
    public view override
    returns (tree.NodeDetails memory) {
    if (tree.isAvailable(_node)) {
      tree.NodeDetails memory ld = details(left(_node));
      tree.NodeDetails memory rd = details(right(_node));
      int bf = ld.height - rd.height;
      return tree.NodeDetails({
        key: _node.key,
        isBalanced: (ld.isBalanced && rd.isBalanced && (-1 <= bf && bf <= 1)),
        height: utils.max(ld.height, rd.height) + 1,
        bf: bf,
        isLeftBalanced: ld.isBalanced,
        leftHeight: ld.height,
        isRightBalanced: rd.isBalanced,
        rightHeight: rd.height
        });
    } else {
      return tree.NodeDetails({
        key: '',
        isBalanced: true,
        height: -1,
        bf: 0,
        isLeftBalanced: true,
        leftHeight: -2,
        isRightBalanced: true,
        rightHeight: -2
        });
    }
  }

  function left(tree.Node memory _node)
    public view override
    returns (tree.Node memory) {
    if (tree.hasLeft(_node)) {
      return nodes[_node.left];
    } else {
      return DUMMY_NODE;
    }
  }

  function right(tree.Node memory _node)
    public view override
    returns (tree.Node memory) {
    if (tree.hasRight(_node)) {
      return nodes[_node.right];
    } else {
      return DUMMY_NODE;
    }
  }
}
