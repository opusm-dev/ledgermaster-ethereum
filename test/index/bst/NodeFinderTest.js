const { v4: uuid } = require('uuid');
const { getStringComparator, getNodeFinder, createTree, addNodeValue, removeNodeValue, checkPath } = require('../../utils/op.js');

const SimpleNodeRepository = artifacts.require('SimpleNodeRepository');
const MinimumFinder = artifacts.require('MinimumFinder');
const NodeFinder = artifacts.require('NodeFinder');
const AvlTreeBalancer = artifacts.require('AvlTreeBalancer');
const AvlTree = artifacts.require('AvlTree');
const AvlTreeManager = artifacts.require("AvlTreeManager");

const minuteInSeconds = 60;
const hourInSeconds = 60 * minuteInSeconds;
const dayInSeconds = 24 * hourInSeconds;

const N_NODE = 4;

contract('NodeFinderTest', (accounts) => {
  let comparator;
  let nodeFinder;
  let tree;
  let repository;
  beforeEach('', async () => {
    comparator = await getStringComparator();
    nodeFinder = await getNodeFinder();
    const all = await createTree(accounts[0]);
    repository = all.repository;
    tree = all.tree;
  });

  /**
   * [1]
   */
  it('test empty', () => {
    return nodeFinder.find(repository.address, comparator.address, '').then(it => assert.equal(it.length, 0));
  });

  it('property based test for find', async () => {
    const set = [...Array(N_NODE).keys()].map(() => uuid().substring(0, 8));
    // add
    await addNodeValue(tree, ...set);

    const root = await repository.getRoot();
    // contains
    for (let i = 0 ; i<set.length ; ++i) {
      const v = set[i];
      await checkPath(nodeFinder, comparator, set[i], repository.address)
        .then(path => expect(path[path.length - 1]).to.eq(v));
    }
  });
});
