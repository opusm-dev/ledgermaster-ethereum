pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Controller.sol';
import "../../Modules.sol";

contract Controlled is Modules {

  modifier onlyModulesGovernor {
    require(msg.sender == owner, 'SENDER_NOT_GOVERNOR');
    _;
  }

  Controller public controller;
  address private owner;

  constructor(address _controller) public {
    controller = Controller(_controller);
    owner = msg.sender;
  }

  function changeOwner(address newOwner) public onlyModulesGovernor {
    owner = newOwner;
  }

  function getModule(uint _id) public view returns (address) {
    return controller.getModule(_id);
  }

  function createModule(uint _id) public returns (address) {
    return controller.createModule(_id);
  }

}
