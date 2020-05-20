const { v4: uuid } = require('uuid');
const { createTree, addNodeValue, removeNodeValue, checkPath } = require('./utils/op.js');

const SimpleNodeRepository = artifacts.require('SimpleNodeRepository');
const MinimumFinder = artifacts.require('MinimumFinder');
const NodeFinder = artifacts.require('NodeFinder');
const AvlTreeBalancer = artifacts.require('AvlTreeBalancer');
const AvlTree = artifacts.require('AvlTree');
const AvlTreeNodeManager = artifacts.require("AvlTreeNodeManager");

const minuteInSeconds = 60;
const hourInSeconds = 60 * minuteInSeconds;
const dayInSeconds = 24 * hourInSeconds;

const N_NODE = 4;

contract('NodeFinder', (accounts) => {
  let tree;
  let repository;
  let nodeFinder;
  beforeEach('', () => {
    return createTree()
      .then(all => {
        tree = all.tree;
        repository = all.repository;
        nodeFinder = all.nodeFinder;
      });
  });

  /**
   * [1]
   */
  it('test empty', () => {
    return nodeFinder.find(repository.address, '').then(it => assert.equal(it.length, 0));
  });

  it('property based test for find', async () => {
    const set = [...Array(N_NODE).keys()].map(() => uuid().substring(0, 8));
    // add
    await addNodeValue(tree, ...set);

    const root = await repository.getRoot();
    // contains
    for (let i = 0 ; i<set.length ; ++i) {
      const v = set[i];
      await checkPath(nodeFinder, set[i], repository.address)
        .then(path => expect(path[path.length - 1]).to.eq(v));
    }
  });
});
