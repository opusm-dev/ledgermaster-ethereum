const { v4: uuid } = require('uuid');
const { getAvlTreeVisitor, createTree, addNodeValue, removeNodeValue, checkPath } = require('../../../utils/op.js');

// Don't change N_NODE!!
// The test cases is dependent on N_NODE.
const N_NODE = 10;
const N_REPEAT = 4;

contract('AvlTreeVisitorTest', (accounts) => {
  let repository;
  let tree;
  let visitor;

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
  beforeEach('set up', async () => {
    visitor = await getAvlTreeVisitor();
    const all = await createTree(accounts[0]);
    repository = all.repository;
    tree = all.tree;
    await addNodeValue(tree, ...Array(N_NODE).keys());
  });

  it('test calculateCandidate', async () => {
    function path(start, startType) {
      return visitor.calculateCandidate(repository.address, { value: start, boundType: startType }, { value: '', boundType: -1 })
        .then(it => it.elements.slice(0, it.index).map(e => e[1]));
    };
    expect(await path('1', 0)).to.eql(['3', '1']);
    expect(await path('3', 0)).to.eql(['3']);
    expect(await path('7', 0)).to.eql(['7']);
    expect(await path('3', 1)).to.eql(['7', '5', '4']);
  });

  it('test countBy', () => {
    function perform(s, st, t, tt, expected) {
      return tree.countBy({ value: s, boundType: st }, { value: t, boundType: tt })
        .then(it => it.toNumber())
        .then(it => expect(it).to.eq(expected));
    };
    return Promise.all([
      perform('1', 1, '5', 0, 4),
      perform('3', 1, '', -1, N_NODE - 4)]);
  });

  it('test findBy', () => {
    // check findBy
    function perform(i) {
      // Generate input
      const n1 = Math.floor(Math.random() * N_NODE);
      const n2 = Math.floor(Math.random() * N_NODE);
      const start = Math.min(n1, n2);
      const end = Math.max(n1, n2);
      const startType = Math.floor(3 * Math.random()) - 1;
      const endType = Math.floor(3 * Math.random()) - 1;

      // Input expression
      const startSymbol = (0 == startType)?'[':'(';
      const startStr = (-1 == startType)?'oo':start.toString();
      const endSymbol = (0 == endType)?']':')';
      const endStr = (-1 == endType)?'oo':end.toString();
      const input = startSymbol + startStr + ',' + endStr + endSymbol;

      // Calculate expected
      const startValue = ((startType == -1)?0:start) + ((startType == 1)?1:0);
      const endValue = ((endType==-1)?(N_NODE):(end+1)) - ((endType == 1)?1:0);
      const expectedCount = Math.max(0, endValue - startValue);
      const expected = [...Array(expectedCount).keys()].map(it => (it + startValue).toString());

      return tree.findBy({ value: start.toString(), boundType: startType}, { value: end.toString(), boundType: endType })
        .then(result => expect(result).to.eql(expected, 'Input: ' + input));
    };
    const input = [...Array(N_REPEAT).keys()];
    return Promise.all(input.map((i) => perform(i)));
  });
});
