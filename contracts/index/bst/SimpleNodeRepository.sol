pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './NodeRepository.sol';
import './PathFinder.sol';
import './TreeNode.sol';
import './TreeNodeUtils.sol';

import '../../common/Math.sol';
import '../../common/proxy/Controlled.sol';

contract SimpleNodeRepository is NodeRepository, Controlled {
  TreeNode DUMMY_NODE = TreeNode({
    kind: 0,
    key: '',
    values: new string[](0),
    left: '',
    right: ''
    });

  mapping(string => TreeNode) private nodes;

  TreeNode private _root = TreeNode({
    kind: bytes1(0x00),
    key: '',
    values: new string[](0),
    left: '',
    right: ''
  });

  constructor(address _controller) Controlled(_controller) public { }

  function create(string memory _key) public override {
    TreeNode memory newNode = TreeNode({
      kind: bytes1(0x01),
      key: _key,
      values: new string[](0),
      left: '',
      right: ''
    });
    nodes[_key] = newNode;
  }

  function get(string memory _key) public view override returns (TreeNode memory) {
    TreeNode memory node = nodes[_key];
    return node;
  }

  function remove(string memory _key) public override {
    delete nodes[_key];
  }

  function set(TreeNode memory _node) public override {
    nodes[_node.key] = _node;
  }

  function add(string memory _key, string memory _value) public override {
    nodes[_key].values.push(_value);
  }

  function remove(string memory _key, string memory _value) public override returns (int) {
    TreeNode storage node = nodes[_key];
    if (!TreeNodeUtils.isAvailable(node)) {
      return -1;
    }
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    uint deletionCount = 0;
    for (uint i = 0 ; i < node.values.length ; ++i) {
      if (comparator.equals(node.values[i], _value)) {
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
    return r;
  }

  function getRoot() public override view returns (TreeNode memory) {
    if (TreeNodeUtils.isAvailable(_root)) {
      return nodes[_root.key];
    } else {
      return _root;
    }
  }

  function setRoot(TreeNode memory _node) public override {
    _root = _node;
  }

  function contains(string memory _key, string memory _value)
  public view override
  returns (bool) {
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    TreeNode memory node = get(_key);
    if (TreeNodeUtils.isAvailable(node)) {
      if (comparator.equals(node.key, _key)) {
        for (uint i = 0 ; i < node.values.length ; ++i) {
          if (comparator.equals(node.values[i], _value)) {
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
  function size(TreeNode memory _node) public view returns (uint) {
    uint s = 0;
    if (TreeNodeUtils.isAvailable(_node)) {
      s = _node.values.length;
      if (TreeNodeUtils.hasLeft(_node)) {
        s += size(get(_node.left));
      }
      if (TreeNodeUtils.hasRight(_node)) {
        s += size(get(_node.right));
      }
    }
    return s;
  }

  function find(uint _finder, string memory _key) public view override returns (TreeNode[] memory) {
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    return PathFinder(controller.getModule(_finder)).find(this, comparator, _key);
  }

  function find(uint _finder, TreeNode memory _node, string memory _key) public view override returns (TreeNode[] memory) {
    Comparator comparator = Comparator(controller.getModule(COMPARATOR));
    return PathFinder(controller.getModule(_finder)).find(this, comparator, _node, _key);
  }


  function details(TreeNode memory _node) public view override returns (TreeNodeDetails memory) {
    if (TreeNodeUtils.isAvailable(_node)) {
      TreeNodeDetails memory ld = details(left(_node));
      TreeNodeDetails memory rd = details(right(_node));
      int bf = ld.height - rd.height;
      return TreeNodeDetails({
        key: _node.key,
        isBalanced: (ld.isBalanced && rd.isBalanced && (-1 <= bf && bf <= 1)),
        height: Math.max(ld.height, rd.height) + 1,
        bf: bf,
        isLeftBalanced: ld.isBalanced,
        leftHeight: ld.height,
        isRightBalanced: rd.isBalanced,
        rightHeight: rd.height
        });
    } else {
      return TreeNodeDetails({
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

  function left(TreeNode memory _node) public view override returns (TreeNode memory) {
    if (TreeNodeUtils.hasLeft(_node)) {
      return nodes[_node.left];
    } else {
      return DUMMY_NODE;
    }
  }

  function right(TreeNode memory _node) public view override returns (TreeNode memory) {
    if (TreeNodeUtils.hasRight(_node)) {
      return nodes[_node.right];
    } else {
      return DUMMY_NODE;
    }
  }
}
