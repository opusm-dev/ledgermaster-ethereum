const { v4: uuid } = require('uuid');
const modules = require('./utils/modules.js');
const { createTree, addNodeValue, removeNodeValue } = require('./utils/op.js');

const NodeRepository = artifacts.require('NodeRepository');

const N_NODE = 8;

contract('AvlTree', (accounts) => {
  let repository;
  let tree;
  let visitor;

  beforeEach('', () => {
    return createTree()
      .then(all => {
        tree = all.tree;
        repository = all.repository;
        visitor = all.visitor;
      });
  });
  it('test empty string key', async () => {
    // add
    await addNodeValue(tree, '');

    // contains
    await repository.contains('', '').then(v => expect(v).to.eq(true));
  });

  it('test add / contains / remove', async () => {
    // add
    const set = Array(N_NODE).fill().map(()=> uuid().substring(0, 8));
    await addNodeValue(tree, ...set);

    // contains
    await Promise.all(set.map(it => repository.contains(it, it))).then(values => values.forEach(v => expect(v).to.eq(true)));

    // remove
    await removeNodeValue(tree, ...set);
  });
});
