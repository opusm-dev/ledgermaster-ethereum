pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Controller.sol';
import './ContractFactory.sol';

import '../BytesUtils.sol';
import '../StringUtils.sol';
import '../UintUtils.sol';

contract ModuleController is Controller {
  string internal constant PREFIX_NO_MODULE = 'NO_MODULE IN ';
  string internal constant PREFIX_DUPLICATED_MODULE = 'DUPLICATED_MODULE: ';
  string internal constant ERR_MODULE_CREATION_FAILURE = 'MODULE_CREATION_FAILURE';
  string internal constant ERR_NOT_CONTROLLED = 'NOT_CONTROLLED';

  modifier onlyModulesGovernor {
    require(msg.sender == owner, 'SENDER_NOT_OWNER');
    _;
  }

  address private owner;
  constructor() public {
    owner = msg.sender;
  }

  mapping (uint => address) internal modules;

  function changeOwner(address newOwner) public onlyModulesGovernor {
    owner = newOwner;
  }

  function createModule(address parent, uint _id) public override returns (address) {
    ContractFactory factory = ContractFactory(getModule(_id));
    address newModule = factory.create(parent, msg.sender);
    require(address(0x0) != newModule, ERR_MODULE_CREATION_FAILURE);
    return newModule;
  }

  function createModule(uint _id) public override returns (address) {
    return createModule(address(this), _id);
  }

  function getModule(uint _id) public override view returns (address) {
    address addrezz = modules[_id];
    require(address(0x0) != addrezz, StringUtils.concat(StringUtils.concat(StringUtils.concat(PREFIX_NO_MODULE, BytesUtils.toString(abi.encodePacked(address(this)))), ': '), UintUtils.toString(_id)));
    return addrezz;
  }

  function setModule(uint _id, address _address) public override onlyModulesGovernor {
    modules[_id] = _address;
  }

}