pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../Modules.sol';
import '../common/proxy/Controller.sol';
import '../common/proxy/ModuleController.sol';

import '../common/proxy/ContractFactory.sol';
import './bst/avl/AvlTree.sol';

contract IndexFactory is ContractFactory, Modules {
  event NewIndex(address addrezz);
  /**
   * Create an index, which contains NodeRepository and AvlTree
   */
  function create(address _controller, address owner) public override returns (address) {
    Controller controller = Controller(_controller);
    ModuleController indexController = new ModuleController();
    address indexControllerAddress = address(indexController);
    address nodeRepository = controller.createModule(indexControllerAddress, NODE_REPOSITORY_FACTORY);
    indexController.setModule(NODE_REPOSITORY, nodeRepository);
    indexController.setModule(STRING_COMPARATOR, controller.getModule(STRING_COMPARATOR));
    indexController.setModule(INTEGER_COMPARATOR, controller.getModule(INTEGER_COMPARATOR));

    indexController.setModule(MIN_FINDER, controller.getModule(MIN_FINDER));
    indexController.setModule(NODE_FINDER, controller.getModule(NODE_FINDER));

    indexController.setModule(MANAGER, controller.getModule(MANAGER));
    indexController.setModule(VISITOR, controller.getModule(VISITOR));
    indexController.setModule(BALANCER, controller.getModule(BALANCER));
    AvlTree tree = new AvlTree(indexControllerAddress);
    indexController.changeOwner(owner);
    tree.changeOwner(owner);
    address addrezz = address(tree);
    emit NewIndex(addrezz);
    return addrezz;
  }
}