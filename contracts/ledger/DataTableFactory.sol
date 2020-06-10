pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "../proxy/Controlled.sol";
import "../proxy/Controller.sol";
import "../proxy/Modules.sol";

import "../ContractFactory.sol";
import "./DataTable.sol";

contract DataTableFactory is ContractFactory, Controlled, Modules {
  string private constant ERR_DUPLICATED = "CONTRACT_DUPLICATED";
  
  mapping(string => address) contracts;

  Controller controller;
  constructor(address _address) public {
    controller = Controller(_address);
  }
  function create(string memory key) public override {
    require(address(0x0) == contracts[key], ERR_DUPLICATED);
    DataTable table = new DataTable();
    table.setModule(ROW_REPOSITORY, controller.getModule(ROW_REPOSITORY));
    table.setModule(NODE_REPOSITORY_FACTORY, controller.getModule(NODE_REPOSITORY_FACTORY));
    //table.setModule(TREE_FACTORY, controller.getModule(TREE_FACTORY));
    table.setModule(MIN_FINDER, controller.getModule(MIN_FINDER));
    table.setModule(NODE_FINDER, controller.getModule(NODE_FINDER));
    table.setModule(INDEX_FACTORY, controller.getModule(INDEX_FACTORY));
    table.changeOwner(msg.sender);
    contracts[key] = address(table);
  }

  function get(string memory key) public view override returns (address) {
    return contracts[key];
  }

}