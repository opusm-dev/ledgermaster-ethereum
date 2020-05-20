const { v4: uuid } = require('uuid');
const { createTree, addNodeValue, removeNodeValue, checkPath } = require('./utils/op.js');

// Don't change N_NODE!!
// The test cases is dependent on N_NODE.
const N_NODE = 10;
const N_REPEAT = 10;

contract('SingleDigitAvlTree', (accounts) => {
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
  beforeEach('', () => {
    return createTree()
      .then(all => {
        visitor = all.visitor;
        tree = all.tree;
        repository = all.repository;
        nodeFinder = all.nodeFinder;
      }).then(() => addNodeValue(tree, ...Array(N_NODE).keys()));

  });

  it('test for finder', async () => {
    return repository.getRoot().then(root => {
      return Promise.all([
        checkPath(nodeFinder, '1', repository.address).then(it => expect(it).to.eql(['3', '1'])),
        checkPath(nodeFinder, '3', repository.address).then(it => expect(it).to.eql(['3'])),
        checkPath(nodeFinder, '7', repository.address).then(it => expect(it).to.eql(['3', '7']))
      ]);
    });
  });
});
