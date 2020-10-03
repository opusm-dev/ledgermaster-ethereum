const { createTree, getMinimumFinder, getStringComparator, addNodeValue, removeNodeValue } = require('../../utils/op.js');

const N_NODE = 4;

contract('MinimumFinderTest', (accounts) => {
  let comparator;
  let tree;
  let repository;
  let minFinder;
  function min(expected) {
    return minFinder.find(repository.address, comparator.address, '')
      .then(it => it[it.length - 1].key)
      .then(it => expect(it).to.eq(expected));
  };

  beforeEach('', async () => {
    comparator = await getStringComparator();
    minFinder = await getMinimumFinder();
    const all = await createTree(accounts[0]);
    repository = all.repository;
    tree = all.tree;
  });

  /**
   * [1]
   */
  it('test empty', async () => {
    const rows = await minFinder.find(repository.address, comparator.address, '')
    expect(rows.length).to.eq(0);
  });

  /**
   * [1]
   */
  it('test root', async () => {
    await addNodeValue(tree, '1')
    min('1');
  });

  /**
   * [1]
   */
  it('test case 1', async () => {
    const input = [...Array(N_NODE).keys()];
    for (let i = 0 ; i<input.length ; ++i) {
      const j = Math.floor(Math.random() * (i + 1));
      let x = input[i];
      input[i] = input[j];
      input[j] = x;
    }

    await addNodeValue(tree, ...input)
    const root = await repository.getRoot();
    await min('0');
  });
});
