pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Interfaces */
import "../Tree.sol";
import "../NodeRepository.sol";
import "../Index.sol";
import "../Balancer.sol";
import "../Visitor.sol";

/* Utilities */
import "../proxy/Modules.sol";
import "../proxy/Controller.sol";

contract AvlTree is Index, Tree, Controller, Modules {
  function getNodeRepository() public view override returns (NodeRepository) {
    return NodeRepository(getModule(NODE_REPOSITORY));
  }

  /**
   * Add value
   */
  function add(string memory _key, string memory _value) public override {
    (bool success, ) = getModule(MANAGER).delegatecall(abi.encodeWithSignature("add(address,string,string)", getNodeRepository(), _key, _value));
    require(success);
  }

  /**
   * Remove value
   */
  function remove(string memory _key, string memory _value) public override {
    (bool success, ) = getModule(MANAGER).delegatecall(abi.encodeWithSignature("remove(address,string,string)", getNodeRepository(), _key, _value));
    require(success);
  }


  /**
   * point type:
   * -1 - unbound
   * 0 - Included bound
   * 1 - Excluded bound
   */
  function findBy(
    string memory start,
    int startType,
    string memory end,
    int endType) public view override returns (string[] memory) {
    require(address(0x0) != getModule(VISITOR), "No Visitor");
    return Visitor(getModule(VISITOR)).findBy(getNodeRepository(), start, startType, end, endType);
  }

  function countBy(
    string memory start,
    int startType,
    string memory end,
    int endType) public view returns (uint) {
    require(address(0x0) != getModule(VISITOR), "No Visitor");
    return Visitor(getModule(VISITOR)).countBy(getNodeRepository(), start, startType, end, endType);
  }
}
