pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../NodeRepository.sol';
import '../TreeBalancer.sol';
import '../TreeVisitor.sol';
import '../../Index.sol';

import '../../../common/ValuePoint.sol';
import '../../../common/proxy/Controlled.sol';

contract AvlTree is Index, Controlled {
  constructor(address _controller) Controlled(_controller) public { }

  function getNodeRepository() public view returns (NodeRepository) {
    return NodeRepository(getModule(NODE_REPOSITORY));
  }

  /**
   * Add value
   */
  function add(string memory _key, string memory _value) public override {
    (bool success, ) = getModule(MANAGER).delegatecall(abi.encodeWithSignature('add(address,string,string)', getNodeRepository(), _key, _value));
    require(success, 'Fail to add');
  }

  /**
   * Remove value
   */
  function remove(string memory _key, string memory _value) public override {
    (bool success, ) = getModule(MANAGER).delegatecall(abi.encodeWithSignature('remove(address,string,string)', getNodeRepository(), _key, _value));
    require(success, 'Fail to remove');
  }

  /**
   * point type:
   * -1 - unbound
   * 0 - Included bound
   * 1 - Excluded bound
   */
  function findBy(ValuePoint memory start, ValuePoint memory end) public view override returns (string[] memory) {
    require(address(0x0) != getModule(VISITOR), 'No Visitor');
    return TreeVisitor(getModule(VISITOR)).findBy(getNodeRepository(), start, end);
  }

  function countBy(ValuePoint memory start, ValuePoint memory end) public view override returns (uint) {
    require(address(0x0) != getModule(VISITOR), 'No Visitor');
    return TreeVisitor(getModule(VISITOR)).countBy(getNodeRepository(), start, end);
  }
}
