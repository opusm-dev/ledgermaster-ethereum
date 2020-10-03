const { v4: uuid } = require('uuid');
const { createTree, addNodeValue, removeNodeValue } = require('./utils/op.js');
const logger = require('./utils/logger.js');

contract('PSMLB-199', (accounts) => {
  let repository;
  let tree;
  let visitor;
  beforeEach('', () => {
    return createTree(accounts[0])
      .then(all => {
        tree = all.tree;
        repository = all.repository;
        visitor = all.visitor;
      });
  });
  /**
   *                      cabd0c73
   *                     /        \
   *              240098a3        dd17db41
   *             /        \       /       \
   *      13538b09   54de1f16  cdb9ce8d   f5466e90
   *                        \
   *                      9e1a08e2
   */
  it('simple', async () => {
    function printNode(key) {
      function padding(s) {
        return (s == '')?'        ':s;
      }
      return repository.get(key).then(node => padding(node.left) + ":" + padding(node.key) + ":" + padding(node.right));
    }
    const inputs = ['f5466e90', 'cabd0c73', '240098a3', 'cdb9ce8d', '13538b09', 'dd17db41', '54de1f16', '9e1a08e2'];
    for (const input of inputs) {
      await addNodeValue(tree, input);
    }
    /**
     *                      cabd0c73
     *                     /        \
     *              240098a3        dd17db41
     *             /        \       /       \
     *      13538b09   54de1f16  cdb9ce8d   f5466e90
     *                        \
     *                      9e1a08e2
     */
    await removeNodeValue(tree, inputs[0]);
    await repository.get('dd17db41').then(n => (expect(n.kind).to.eql('0x09')));
    /**
     *                      cabd0c73
     *                     /        \
     *              240098a3        dd17db41
     *             /        \       /
     *      13538b09   54de1f16  cdb9ce8d
     *                        \
     *                      9e1a08e2
     */
    await removeNodeValue(tree, inputs[1]);
    /**
     *                      cdb9ce8d
     *                     /        \
     *              240098a3        dd17db41
     *             /        \
     *      13538b09   54de1f16
     *                        \
     *                      9e1a08e2
     */
    await removeNodeValue(tree, inputs[2]);
    /**
     *                      54de1f16
     *                     /        \
     *              240098a3        cdb9ce8d
     *             /                /      \
     *      13538b09          9e1a08e2    dd17db41
     */
    await removeNodeValue(tree, inputs[3]);
    await removeNodeValue(tree, inputs[4]);
    await removeNodeValue(tree, inputs[5]);
    await removeNodeValue(tree, inputs[6]);
    await removeNodeValue(tree, inputs[7]);
  });

});
