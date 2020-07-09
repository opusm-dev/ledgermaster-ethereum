const MinimumFinder = artifacts.require('MinimumFinder');
const NodeFinder = artifacts.require('NodeFinder');
const SimpleNodeRepository = artifacts.require('SimpleNodeRepository');
const AvlTreeBalancer = artifacts.require('AvlTreeBalancer');
const AvlTreeVisitor = artifacts.require('AvlTreeVisitor');
const AvlTreeNodeManager = artifacts.require('AvlTreeNodeManager');
const AvlTree = artifacts.require('AvlTree');
const DataTableColumns = artifacts.require('DataTableColumns');
const DataTableConstraints = artifacts.require('DataTableConstraints');

module.exports = function(deployer) {
  deployer.deploy(DataTableColumns);
  deployer.deploy(DataTableConstraints);
  deployer.deploy(MinimumFinder);
  deployer.deploy(NodeFinder);
  deployer.deploy(NodeFinder);
  deployer.deploy(AvlTreeBalancer);
  deployer.deploy(AvlTreeVisitor);
  deployer.deploy(AvlTreeNodeManager);
  deployer.deploy(SimpleNodeRepository);
  deployer.deploy(AvlTree);
};

