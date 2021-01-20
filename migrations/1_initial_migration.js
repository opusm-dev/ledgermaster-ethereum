const StringComparator = artifacts.require('StringComparator');
const IntegerComparator = artifacts.require('IntegerComparator');

const ModuleController = artifacts.require('ModuleController');
const MinimumFinder = artifacts.require('MinimumFinder');
const NodeFinder = artifacts.require('NodeFinder');

const AvlTreeBalancer = artifacts.require('AvlTreeBalancer');
const AvlTreeVisitor = artifacts.require('AvlTreeVisitor');
const DataTableVisitor = artifacts.require('DataTableVisitor');
const AvlTreeManager = artifacts.require('AvlTreeManager');
const DataTableColumns = artifacts.require('DataTableColumns');
const DataTableIndices = artifacts.require('DataTableIndices');
const DataTableConstraints = artifacts.require('DataTableConstraints');

const SimpleNodeRepositoryFactory = artifacts.require('SimpleNodeRepositoryFactory');
const HashIndexFactory = artifacts.require('HashIndexFactory');
const SortIndexFactory = artifacts.require('IndexFactory');
const DataTableFactory = artifacts.require('DataTableFactory');
const modules = require('../test/utils/modules.js');

module.exports = async function(deployer) {
  await deployer.deploy(ModuleController);
  const controller = await ModuleController.deployed();

  // common
  await deployer.deploy(StringComparator).then(it => controller.setModule(modules.STRING_COMPARATOR, it.address));
  await deployer.deploy(IntegerComparator).then(it => controller.setModule(modules.INTEGER_COMPARATOR, it.address));

  await deployer.deploy(StringComparator).then(it => controller.setModule(modules.COMPARATOR, it.address));
  // index

  await deployer.deploy(MinimumFinder).then(it => controller.setModule(modules.MIN_FINDER, it.address));
  await deployer.deploy(NodeFinder).then(it => controller.setModule(modules.NODE_FINDER, it.address));
  await deployer.deploy(DataTableColumns, ModuleController.address).then(it => controller.setModule(modules.TABLE_COLUMNS, it.address));
  await deployer.deploy(DataTableIndices, ModuleController.address).then(it => controller.setModule(modules.TABLE_INDICES, it.address));
  await deployer.deploy(DataTableConstraints).then(it => controller.setModule(modules.TABLE_CONSTRAINTS, it.address));
  await deployer.deploy(AvlTreeBalancer, ModuleController.address).then(it => controller.setModule(modules.BALANCER, it.address));
  await deployer.deploy(AvlTreeVisitor, ModuleController.address).then(it => controller.setModule(modules.VISITOR, it.address));
  await deployer.deploy(DataTableVisitor, ModuleController.address).then(it => controller.setModule(modules.TABLE_VISITOR, it.address));
  await deployer.deploy(AvlTreeManager, ModuleController.address).then(it => controller.setModule(modules.MANAGER, it.address));
  await deployer.deploy(SimpleNodeRepositoryFactory, ModuleController.address).then(it => controller.setModule(modules.NODE_REPOSITORY_FACTORY, it.address));
  await deployer.deploy(HashIndexFactory, ModuleController.address).then(it => controller.setModule(modules.HASH_INDEX_FACTORY, it.address));
  await deployer.deploy(SortIndexFactory, ModuleController.address).then(it => controller.setModule(modules.SORT_INDEX_FACTORY, it.address));
  await deployer.deploy(DataTableFactory, ModuleController.address).then(it => controller.setModule(modules.TABLE_FACTORY, it.address));
};
