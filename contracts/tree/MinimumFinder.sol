pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Interfaces */
import "../PathFinder.sol";
import "../NodeRepository.sol";

/* Utilities */
import "../lib/system.sol";
import "../lib/tree.sol";

contract MinimumFinder is PathFinder {
  function find(NodeRepository _repository, string memory extra) public view override returns (tree.Node[] memory) {
    return find(_repository, _repository.getRoot(), extra);
  }
  function find(NodeRepository _repository, tree.Node memory _node, string memory extra) public view override returns (tree.Node[] memory) {
    if (tree.isAvailable(_node)) {
      tree.Node[] memory path = find(_repository, _repository.left(_node), extra);
      tree.Node[] memory newPath = new tree.Node[](path.length + 1);
      for (uint i=0 ; i<path.length ; ++i) {
        newPath[i + 1] = path[i];
      }
      newPath[0] = _node;
      return newPath;
    } else {
      return new tree.Node[](0);
    }
  }
}
