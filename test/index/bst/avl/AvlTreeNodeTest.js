const { createTree, addNodeValue, removeNodeValue } = require('../../../utils/op.js');

const minuteInSeconds = 60;
const hourInSeconds = 60 * minuteInSeconds;
const dayInSeconds = 24 * hourInSeconds;

contract('AvlTreeNodeTest', (accounts) => {
  let repository;
  let tree;
  function check() {
    const nArgs = 3;
    const extract = arguments[0];
    const args = [...arguments].slice(1).map(it => it.toString());
    return Promise.all(
      Array(nArgs).fill()
        .map((v, i) => i + 1)
        .map(it => it.toString())
        .map(it => repository.get(it).then(node => repository.details(node)).then(extract)))
        .then((values) => {
        assert.deepEqual(values, args); });
  };

  function checkBf() {
    return check.call(null, (d) => d.bf, ...arguments);
  };
  function checkHeight() {
    return check.call(null, (d) => d.height, ...arguments);
  };
  function balance() {
    return tree.balance();
  };

  beforeEach('', async () => {
    const all = await createTree(accounts[0]);
    tree = all.tree;
    repository = all.repository;
  });

  /**
   * [1]
   */
  it('test root', () => {
    return addNodeValue(tree, '1')
      .then(() => removeNodeValue(tree, '1'));
  });

  /**
   *         [2]
   *        /   \
   *     [1]     [3]
   */
  it('test remove', () => {
    return addNodeValue(tree, '2', '1', '3')
      .then(() => checkHeight(0, 1, 0))
      .then(() => checkBf(0, 0, 0))
      .then(() => removeNodeValue(tree, '1', '2', '3'));
  });

  /**
   *         [2]
   *        /   \
   *     [1]     [3]
   */
  it('test remove root', () => {
    return addNodeValue(tree, '1', '2', '3')
      .then(() => removeNodeValue(tree, '2', '3', '1'));
  });

  it('test remove case1', () => {
    return addNodeValue(tree, 'd80feea7', '5fb01fb2', '69c545c3', '232a8523')
      .then(() => removeNodeValue(tree, 'd80feea7', '5fb01fb2', '69c545c3', '232a8523'));
  });

  /**
   *         [3]
   *        /
   *     [2]
   *    /
   * [1]
   */
  it('test type1', () => {
    return addNodeValue(tree, '3', '2', '1')
      .then(() => checkHeight(0, 1, 0))
      .then(() => checkBf(0, 0, 0))
      .then(() => removeNodeValue(tree, '1', '2', '3'));
  });

  /**
   *  [1]
   *    \
   *     [2]
   *       \
   *        [3]
   */
  it('test type2', () => {
    return addNodeValue(tree, '1', '2', '3')
      .then(() => checkHeight(0, 1, 0))
      .then(() => checkBf(0, 0, 0))
      .then(() => removeNodeValue(tree, '1', '2', '3'));
  });

  /**
   *       [3]
   *      /
   *    [1]
   *      \
   *       [2]
   */
  it('test type3', () => {
    return addNodeValue(tree, '3', '1', '2')
      .then(() => checkHeight(0, 1, 0))
      .then(() => checkBf(0, 0, 0))
      .then(() => removeNodeValue(tree, '1', '2', '3'));
  });

  /**
   *      [1]
   *         \
   *          [3]
   *        /
   *      [2]
   */
  it('test type4', () => {
    return addNodeValue(tree, '1', '3', '2')
      .then(() => checkHeight(0, 1, 0))
      .then(() => checkBf(0, 0, 0))
      .then(() => removeNodeValue(tree, '1', '2', '3'));
  });
});
