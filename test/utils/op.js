const { v4: uuid } = require('uuid');

const logger = require('./logger.js');
const modules = require('./modules.js');

const ModuleController = artifacts.require('ModuleController');
const StringComparator = artifacts.require('StringComparator');
const IntegerComparator = artifacts.require('IntegerComparator');
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

const DataTableStore = artifacts.require('DataTableStore');
const DataTable = artifacts.require('DataTable');
const SimpleNodeRepository = artifacts.require('SimpleNodeRepository');
const AvlTree = artifacts.require('AvlTree');

async function configureController(controller) {
  await controller.setModule(modules.STRING_COMPARATOR, (await StringComparator.deployed()).address);
  await controller.setModule(modules.INTEGER_COMPARATOR, (await IntegerComparator.deployed()).address);
  /* Index part */
  await controller.setModule(modules.MIN_FINDER, (await MinimumFinder.deployed()).address);
  await controller.setModule(modules.NODE_FINDER, (await NodeFinder.deployed()).address);
  await controller.setModule(modules.NODE_REPOSITORY_FACTORY, (await SimpleNodeRepositoryFactory.deployed()).address);

  await controller.setModule(modules.HASH_INDEX_FACTORY, (await HashIndexFactory.deployed()).address);
  await controller.setModule(modules.SORT_INDEX_FACTORY, (await SortIndexFactory.deployed()).address);
  await controller.setModule(modules.BALANCER, (await AvlTreeBalancer.deployed()).address);
  await controller.setModule(modules.VISITOR, (await AvlTreeVisitor.deployed()).address);
  await controller.setModule(modules.TABLE_VISITOR, (await DataTableVisitor.deployed()).address);
  await controller.setModule(modules.MANAGER, (await AvlTreeManager.deployed()).address);

  /* Table part */
  await controller.setModule(modules.TABLE_COLUMNS, (await DataTableColumns.deployed()).address);
  await controller.setModule(modules.TABLE_CONSTRAINTS, (await DataTableConstraints.deployed()).address);
  await controller.setModule(modules.TABLE_INDICES, (await DataTableIndices.deployed()).address);
}

async function globalController() {
  return await ModuleController.deployed();
}
async function createStore() {
  return await globalController().then(it => DataTableStore.new(it.address));
}

async function createTree(account, dataType) {
  const controller = await globalController();
  const indexFactory = await getSortIndexFactory();
  const tx = await indexFactory.create(controller.address, account);
  const log = tx.receipt.logs.filter(log => log.event == 'NewIndex')[0];
  const tree = await AvlTree.at(log.args['addrezz']);
  const c = await ModuleController.at(await tree.controller());
  if (2 == dataType) {
    c.setModule(modules.COMPARATOR, (await IntegerComparator.deployed()).address);
  } else {
    c.setModule(modules.COMPARATOR, (await StringComparator.deployed()).address);
  }

  const repository = await SimpleNodeRepository.at(await tree.getModule(modules.NODE_REPO));
  return { tree, repository };
}

async function createController() {
  const controller = await ModuleController.new();
  await configureController(controller);
  return controller;
}

async function createTable(store, tableName, keyColumnName) {
  const type = 1;
  const controller = await globalController();
  const table = await DataTable.new(controller.address);
  const storeAddress = (null == store)?'0x0000000000000000000000000000000000000000':(store.address);
  await table.initialize(storeAddress, tableName, keyColumnName, 1);
  const metadata = await table.getMetadata();
  const columnNames = metadata.columns.map(it => it.name);
  expect(columnNames).to.include(keyColumnName);
  return table;
}


async function getSortIndexFactory() {
  return SortIndexFactory.at(await globalController().then(it => it.getModule(modules.SORT_INDEX_FACTORY)));
}
async function getStringComparator() {
  return StringComparator.at(await globalController().then(it => it.getModule(modules.STRING_COMPARATOR)));
}
async function getNodeFinder() {
  return NodeFinder.at(await globalController().then(it => it.getModule(modules.NODE_FINDER)));
}

function addNodeValue(value, tree) {
  logger.action('Add ' + value + ' to ' + tree.address.substring(0, 10));
  const valueStr = value.toString();
  return tree.getModule(modules.NODE_REPO)
    .then(address => SimpleNodeRepository.at(address))
    .then(repository => {
      return Promise.all([repository.size()]).then(values => {
        const size = parseInt(values[0]);
        return tree.add(valueStr, valueStr)
          .then(() => repository.getRoot())
          .then(root => repository.details(root))
          .then(details => expect(details.isBalanced).to.eq(true))
          .then(() => repository.contains(valueStr, valueStr).then(it => expect(it).to.eq(it, true)))
          .then(() => repository.size().then(it => expect(it.toNumber()).to.eql(size + 1)));
      });
    });
}

function removeNodeValue(value, tree) {
  logger.action('Remove ' + value + ' from ' + tree.address.substring(0, 10));
  const valueStr = value.toString();
  return tree.getModule(modules.NODE_REPO)
    .then(address => SimpleNodeRepository.at(address))
    .then(repository => {
      return Promise.all([repository.size()]).then(values => {
        const size = parseInt(values[0]);
        return tree.remove(valueStr, valueStr)
          .then(() => repository.getRoot())
          .then(root => repository.details(root))
          .then(details => expect(details.isBalanced).to.eq(true))
          .then(() => repository.contains(valueStr, valueStr).then(it => expect(it).to.eq(false)))
          .then(() => repository.size().then(it => {
            return expect(it.toNumber()).to.eql(size - 1);
          }));
      });
    });
}

function registerTable(address, ts) {
  logger.action('Register a table address ' + address);
  return ts.registerTable(address)
    .then(() => ts.listTableNames())
    .then(tableNames => Promise.all(tableNames.map(name => ts.getTable(name))))
    .then(addresses => expect(addresses).to.include(address));
}

function deregisterTable(name, ts) {
  logger.action('Deregister a table ' + name);
  return ts.deregisterTable(name)
    .then(() => ts.listTableNames())
    .then(names => expect(names).to.not.include(name));
}

function addColumn(column, table) {
  logger.action('Add a column ' + column.name + '[' + column.type + '] to ' + table.address.substring(0, 10));
  return table.addColumn({name: column.name, dataType: column.type})
    .then(() => table.getMetadata())
    .then(meta => meta.columns)
    .then(columns => columns.map(it => it.name))
    .then(columnNames => expect(columnNames).to.include(column.name));
}

function dropColumn(name, table) {
  logger.action('Remove the column ' + name + ' from ' + table.address.substring(0, 10));
  return table.dropColumn(name)
    .then(() => table.getMetadata())
    .then(meta => meta.columns)
    .then(columns => columns.map(it => it.columnName))
    .then(columnNames => expect(columnNames).to.not.include(name));
}

function addIndex(index, table) {
  logger.action('Add an index ' + index.name + '[' + index.column + '] from ' + table.address.substring(0, 10));
  return table.addIndex(index.name, 1, index.column)
    .then(() => table.getMetadata())
    .then(meta => meta.indices)
    .then(indices => indices.map(it => it.indexName))
    .then(indexNames => expect(indexNames).to.deep.include(index.name));
}

function dropIndex(name, table) {
  logger.action('Remove the index ' + name + ' from ' + table.address.substring(0, 10));
  return table.dropIndex(name)
    .then(() => table.getMetadata())
    .then(meta => meta.indices.map(it => it.indexName))
    .then(indexNames => expect(indexNames).to.not.include(name));
}

function addRow(row, table) {
  logger.action('Add row ' + row.values[0] + ' to ' + table.address.substring(0, 10));
  return table.getRow(row.values[0])
    .then(r => expect(r).to.have.lengthOf(0))
    .then(() => table.add(row.values))
    .then(() => table.getRow(row.values[0]))
    .then(r => {
      expect(r).to.have.lengthOf(row.values.length);
      expect(r).to.eql(row.values);
    });
}

function updateRow(row, table) {
  logger.action('Update row ' + row.values[0]);
  return table.getRow(row.values[0])
    .then(r => expect(r).to.not.have.lengthOf(0))
    .then(() => table.update(row.values))
    .then(() => table.getRow(row.values[0]))
    .then(r => {
      expect(r).to.not.have.lengthOf(0);
      expect(r).to.eql(row.values);
    });
}

function removeRow(key, table) {
  logger.action('Remove row ' + key + ' from ' + table.address.substring(0, 10));
  return table.getRow(key)
    .then(r => expect(r).to.not.have.lengthOf(0))
    .then(() => table.remove(key))
    .then(() => table.getRow(key))
    .then(r => expect(r).to.have.lengthOf(0));
}

function callRecursively() {
  const func = arguments[0];
  const index = arguments[1];
  const values = arguments[2];
  const args = [].slice.call(arguments, 3);
  if (index < values.length) {
    return func.call(func, values[index], ...args)
      .then(() => callRecursively(func, index + 1, values, ...args));
  } else {
    return "";
  }
}



module.exports = {
  /* Avl tree */
  addNodeValue: function() {
    const tree = arguments[0];
    return callRecursively(addNodeValue, 0, [].slice.call(arguments, 1), tree);
  },
  removeNodeValue: function() {
    const tree = arguments[0];
    return callRecursively(removeNodeValue, 0, [].slice.call(arguments, 1), tree);
  },
  /* Table Store */
  registerTable: function() {
    const ts = arguments[0];
    return callRecursively(registerTable, 0, [].slice.call(arguments, 1), ts);
  },
  deregisterTable: function() {
    const ts = arguments[0];
    return callRecursively(deregisterTable, 0, [].slice.call(arguments, 1), ts);
  },
  /* Table Governance */
  addColumn: function() {
    const table = arguments[0];
    return callRecursively(addColumn, 0, [].slice.call(arguments, 1), table);
  },
  dropColumn: function() {
    const table = arguments[0];
    return callRecursively(dropColumn, 0, [].slice.call(arguments, 1), table);
  },
  addIndex: function() {
    const table = arguments[0];
    return callRecursively(addIndex, 0, [].slice.call(arguments, 1), table);
  },
  dropIndex: function() {
    const table = arguments[0];
    return callRecursively(dropIndex, 0, [].slice.call(arguments, 1), table);
  },

  /* Row */
  addRow: function() {
    const table = arguments[0];
    return callRecursively(addRow, 0, [].slice.call(arguments, 1), table);
  },
  updateRow: function() {
    const table = arguments[0];
    return callRecursively(updateRow, 0, [].slice.call(arguments, 1), table);
  },
  removeRow: function() {
    const table = arguments[0];
    return callRecursively(removeRow, 0, [].slice.call(arguments, 1), table);
  },
  getStringComparator: async function() {
    return StringComparator.at(await globalController().then(it => it.getModule(modules.COMPARATOR)));
  },
  getMinimumFinder: async function() {
    return MinimumFinder.at(await globalController().then(it => it.getModule(modules.MIN_FINDER)));
  },
  getNodeFinder: async function() {
    return NodeFinder.at(await ModuleController.deployed().then(it => it.getModule(modules.NODE_FINDER)));
  },
  getAvlTreeVisitor: async function() {
    return AvlTreeVisitor.at(await globalController().then(it => it.getModule(modules.VISITOR)));
  },
  getAvlTreeManager: async function() {
    return AvlTreeManager.at(await globalController().then(it => it.getModule(modules.MANAGER)));
  },
  globalController,
  getNodeFinder,
  getStringComparator,
  getSortIndexFactory: getSortIndexFactory,
  createController,
  createStore,
  createTable,
  createTree,
  checkPath: function(finder, comparator, target, repository) {
    return finder.find(repository, comparator.address, target.toString())
      .then((it) => it.map(n => n.key));
  }
};
