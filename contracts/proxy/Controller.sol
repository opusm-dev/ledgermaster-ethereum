pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "./Controlled.sol";
import "../NodeRepository.sol";
import "../PathFinder.sol";
import "../Index.sol";
import "../ContractFactory.sol";

contract Controller is Controlled {
  string internal constant ERR_NO_MODULE = "CTR_NO_MODULE";
  string internal constant ERR_MODULE_CREATION_FAILURE = "CTR_MODULE_CREATION_FAILURE";
  string internal constant ERR_NOT_CONTROLLED = "CTR_NOT_CONTROLLED";

  mapping (uint => address) internal modules;

  function createModule(uint _id, string memory key) public returns (address) {
    require(address(0x0) != modules[_id], ERR_NO_MODULE);
    ContractFactory factory = ContractFactory(modules[_id]);
    factory.create(key);
    address newModule = factory.get(key);
    require(address(0x0) != newModule, ERR_MODULE_CREATION_FAILURE);
    Controlled(newModule).changeOwner(msg.sender);
    return newModule;
  }

  function getModule(uint _id) public view returns (address) {
    return modules[_id];
  }

  function setModule(uint _id, address _address) public onlyModulesGovernor {
    modules[_id] = _address;
  }
}
