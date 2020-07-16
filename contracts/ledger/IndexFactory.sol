pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../proxy/Controlled.sol';
import '../proxy/Controller.sol';
import '../proxy/Modules.sol';

import '../ContractFactory.sol';
import '../tree/AvlTree.sol';

contract IndexFactory is ContractFactory, Controlled, Modules {
  mapping(string => address) contracts;
  Controller controller;
  constructor(address _address) public {
    controller = Controller(_address);
  }
  function create(string memory key) public override {
    require(address(0) == contracts[key]);
    address repository = controller.createModule(NODE_REPOSITORY_FACTORY, key);
    Controller(repository).setModule(MIN_FINDER, controller.getModule(MIN_FINDER));
    Controller(repository).setModule(NODE_FINDER, controller.getModule(NODE_FINDER));
    Controlled(repository).changeOwner(msg.sender);

    // Dangerous casting!!
    AvlTree tree = new AvlTree();
    tree.setModule(VISITOR, controller.getModule(VISITOR));
    tree.setModule(BALANCER, controller.getModule(BALANCER));
    tree.setModule(MANAGER, controller.getModule(MANAGER));
    tree.setModule(NODE_REPOSITORY, repository);
    tree.changeOwner(msg.sender);
    contracts[key] = address(tree);
  }

  function get(string memory key) public view override returns (address) {
    return contracts[key];
  }
}