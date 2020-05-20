const { createTree, addNodeValue, removeNodeValue } = require('./utils/op.js');

const N_NODE = 4;

contract('MinimumFinder', (accounts) => {
  let tree;
  let repository;
  let minFinder;
  function min(expected) {
    return minFinder.find(repository.address, '')
      .then(it => it[it.length - 1].key)
      .then(it => expect(it).to.eq(expected));
  };

  beforeEach('', () => {
    return createTree()
      .then(all => {
        repository = all.repository;
        tree = all.tree;
        minFinder = all.minFinder;
      });
  });

  /**
   * [1]
   */
  it('test empty', () => {
    return minFinder.find(repository.address, '').then(it => assert.equal(it.length, 0));
  });

  /**
   * [1]
   */
  it('test root', () => {
    return addNodeValue(tree, '1').then(() => min('1'));
  });

  /**
   * [1]
   */
  it('test case 1', () => {
    const input = [...Array(N_NODE).keys()];
    for (let i = 0 ; i<input.length ; ++i) {
      const j = Math.floor(Math.random() * (i + 1));
      let x = input[i];
      input[i] = input[j];
      input[j] = x;
    }

    return addNodeValue(tree, ...input)
      .then(() => repository.getRoot())
      .then(root => min('0'));
  });
});
