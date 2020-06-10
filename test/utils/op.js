const { v4: uuid } = require('uuid');

const logger = require('./logger.js');
const modules = require('./modules.js');

const DataTable = artifacts.require('DataTable');
const SimpleRowRepository = artifacts.require('SimpleRowRepository');
const SimpleNodeRepositoryFactory = artifacts.require('SimpleNodeRepositoryFactory');
const AvlTree = artifacts.require('AvlTree');
const SimpleNodeRepository = artifacts.require('SimpleNodeRepository');
const MinimumFinder = artifacts.require('MinimumFinder');
const NodeFinder = artifacts.require('NodeFinder');
const AvlTreeBalancer = artifacts.require('AvlTreeBalancer');
const AvlTreeVisitor = artifacts.require('AvlTreeVisitor');
const AvlTreeNodeManager = artifacts.require("AvlTreeNodeManager");
const IndexFactory = artifacts.require('IndexFactory');

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
          .then(() => repository.size().then(it => expect(it.toNumber()).to.eql(size - 1)));
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

function addColumn(name, table) {
  const type = 1;
  logger.action('Add a column ' + name + '[' + type + '] to ' + table.address.substring(0, 10));
  return table.addColumn(name, 1)
    .then(() => table.getMetadata())
    .then(meta => meta.columns)
    .then(columns => columns.map(it => it.columnName))
    .then(columnNames => expect(columnNames).to.include(name));
}

function removeColumn(name, table) {
  logger.action('Remove the column ' + name + ' from ' + table.address.substring(0, 10));
  return table.removeColumn(name)
    .then(() => table.getMetadata())
    .then(meta => meta.columns)
    .then(columns => columns.map(it => it.columnName))
    .then(columnNames => expect(columnNames).to.not.include(name));
}

function addIndex(index, table) {
  logger.action('Add an index ' + index.name + '[' + index.column + '] from ' + table.address.substring(0, 10));
  return table.addIndex(index.name, index.column)
    .then(() => table.getMetadata())
    .then(meta => meta.indices)
    .then(indices => indices.map(it => ({name: it.indexName, column: it.columnName})))
    .then(indices => expect(indices).to.deep.include(index));
}

function removeIndex(name, table) {
  logger.action('Remove the index ' + name + ' from ' + table.address.substring(0, 10));
  return table.removeIndex(name)
    .then(() => table.getMetadata())
    .then(meta => meta.indices.map(it => it.indexName))
    .then(indexNames => expect(indexNames).to.not.include(name));
}

function addRow(row, table) {
  logger.action('Add row ' + row.values[0] + ' to ' + table.address.substring(0, 10));
  const localMap = {};
  [...row.names.keys()].forEach(i => localMap[row.names[i]] = row.values[i]);
  return table.getRow(row.values[0])
    .then(r => expect(r.available).to.eq(false))
    .then(() => table.addRow(row))
    .then(() => table.getRow(row.values[0]))
    .then(r => {
      expect(r.available).to.eq(true);
      const remoteMap = {};
      [...r[0].keys()].forEach(i => remoteMap[r[0][i]] = r[1][i]);
      expect(remoteMap).to.eql(localMap);
    });
}

function updateRow(row, table) {
  logger.action('Update row ' + row.values[0]);
  const localMap = {};
  [...row.names.keys()].forEach(i => localMap[row.names[i]] = row.values[i]);
  return table.getRow(row.values[0])
    .then(r => expect(r.available).to.eq(true))
    .then(() => table.updateRow(row))
    .then(() => table.getRow(row.values[0]))
    .then(r => {
      expect(r.available).to.eq(true);
      const remoteMap = {};
      [...r[0].keys()].forEach(i => remoteMap[r[0][i]] = r[1][i]);
      expect(remoteMap).to.eql(localMap);
    });
}

function removeRow(key, table) {
  logger.action('Remove row ' + key + ' from ' + table.address.substring(0, 10));
  return table.getRow(key)
    .then(r => expect(r.available).to.eq(true))
    .then(() => table.removeRow(key))
    .then(() => table.getRow(key))
    .then(r => expect(r.available).to.eq(false));
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
  removeColumn: function() {
    const table = arguments[0];
    return callRecursively(removeColumn, 0, [].slice.call(arguments, 1), table);
  },
  addIndex: function() {
    const table = arguments[0];
    return callRecursively(addIndex, 0, [].slice.call(arguments, 1), table);
  },
  removeIndex: function() {
    const table = arguments[0];
    return callRecursively(removeIndex, 0, [].slice.call(arguments, 1), table);
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
  createTree: function() {
    return Promise.all([
      AvlTree.new(),
      SimpleNodeRepository.new(),
      MinimumFinder.deployed(),
      NodeFinder.deployed(),
      AvlTreeBalancer.deployed(),
      AvlTreeVisitor.deployed(),
      AvlTreeNodeManager.deployed()
    ]).then(values => {
      const tree = values[0];
      const repository = values[1];
      const minFinder = values[2];
      const nodeFinder = values[3];
      const balancer = values[4];
      const visitor = values[5];
      const manager = values[6];

    return repository.setModule(modules.MIN_FINDER, minFinder.address)
      .then(() => repository.setModule(modules.NODE_FINDER, nodeFinder.address))
      .then(() => tree.setModule(modules.BALANCER, balancer.address))
      .then(() => tree.setModule(modules.VISITOR, visitor.address))
      .then(() => tree.setModule(modules.MANAGER, manager.address))
      .then(() => tree.setModule(modules.NODE_REPO, repository.address))
      .then(() => ({ tree, repository, minFinder, nodeFinder, balancer, visitor, manager }));
   });
  },
  createTreeFromFactory: function() {
    let tree;
    return AvlTreeFactory.new()
      .then(factory => {
        const key = uuid();
        factory.create(key);
        return factory.get(key);
      })
      .then(address => AvlTree.at(address))
      .then(tree => configure(tree))
  },

  createTable: function(tableName, keyColumnName) {
    const type = 1;
    let table;
    return Promise.all([
      DataTable.new(),
      SimpleRowRepositoryFactory.new(),
      SimpleNodeRepositoryFactory.new(),
      MinimumFinder.deployed(),
      NodeFinder.deployed(),
      AvlTreeBalancer.deployed(),
      AvlTreeVisitor.deployed(),
      AvlTreeNodeManager.deployed()])
      .then((values) => {
        const table = values[0];
        const rowRepository = values[1]
        const repositoryFactory = values[2];
        const minFinder = values[3];
        const nodeFinder = values[4];
        const balancer = values[5];
        const visitor = values[6];
        const manager = values[7];

        return table.setModule(modules.NODE_REPOSITORY_FACTORY, repositoryFactory.address)
        .then(() => table.setModule(modules.ROW_REPOSITORY, rowRepository.address))
        .then(() => table.setModule(modules.MIN_FINDER, minFinder.address))
        .then(() => table.setModule(modules.NODE_FINDER, nodeFinder.address))
        .then(() => table.setModule(modules.BALANCER, balancer.address))
        .then(() => table.setModule(modules.VISITOR, visitor.address))
        .then(() => table.setModule(modules.MANAGER, manager.address))
        .then(() => table)
      })
      .then(t => table = t)
      .then(() => IndexFactory.new(table.address))
      .then((idxFactory) => table.setModule(modules.INDEX_FACTORY, idxFactory.address))
      .then(() => table.initialize(tableName, keyColumnName, 1))
      .then(() => table.getMetadata())
      .then(meta => meta.columns)
      .then(columns => columns.map(it => it.columnName))
      .then(columnNames => expect(columnNames).to.include(keyColumnName))
      .then(() => table);
  },
  checkPath: function(finder, target, repository) {
    return finder.find(repository, target.toString())
      .then((it) => it.map(n => n.key));
  }
};
