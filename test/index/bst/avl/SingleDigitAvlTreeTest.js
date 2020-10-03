const { v4: uuid } = require('uuid');
const { globalController, getStringComparator, getNodeFinder, createTree, addNodeValue, removeNodeValue, checkPath } = require('../../../utils/op.js');
const modules = require('../../../utils/modules.js');

// Don't change N_NODE!!
// The test cases is dependent on N_NODE.
const N_NODE = 10;
const N_REPEAT = 4;

contract('SingleDigitAvlTreeTest', (accounts) => {
  let comparator;
  let nodeFinder;
  let repository;
  let tree;
    /*(3)
     *  L:1
     *    L:0
     *    R:2
     *  R:7
     *    L:5
     *      L:4
     *      R:6
     *    R:8
     *      R:9
     */
  beforeEach('', async () => {
    comparator = await getStringComparator()
    nodeFinder = await getNodeFinder()
    await createTree(accounts[0])
      .then(all => {
        tree = all.tree;
        repository = all.repository;
      }).then(() => addNodeValue(tree, ...Array(N_NODE).keys()));

  });

  it('test for finder', async () => {
    return repository.getRoot().then(root => {
      return Promise.all([
        checkPath(nodeFinder, comparator, '1', repository.address).then(it => expect(it).to.eql(['3', '1'])),
        checkPath(nodeFinder, comparator, '3', repository.address).then(it => expect(it).to.eql(['3'])),
        checkPath(nodeFinder, comparator, '7', repository.address).then(it => expect(it).to.eql(['3', '7']))
      ]);
    });
  });
});
