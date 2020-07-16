pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

contract Controlled {
  string private constant ERR_SENDER_NOT_GOVERNOR = 'CTR_SENDER_NOT_GOVERNOR';
  modifier onlyModulesGovernor {
    require(msg.sender == owner, ERR_SENDER_NOT_GOVERNOR);
    _;
  }

  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address newOwner) public onlyModulesGovernor {
    owner = newOwner;
  }
}
