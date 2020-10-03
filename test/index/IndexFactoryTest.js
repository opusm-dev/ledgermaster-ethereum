const { v4: uuid } = require('uuid');
const { createController, getIndexFactory } = require('../utils/op.js');

const N_NODE = 8;

contract('IndexFactoryTest', (accounts) => {
  let indexFactory;
  beforeEach('', async () => {
    indexFactory = await getIndexFactory();
  });
  it('create', async () => {
    const key = uuid();
    const controller = await createController();
    const tx = await indexFactory.create(controller.address, accounts[0]);
    const log = tx.receipt.logs[0];
    const repositoryAddress = log.args['addrezz'];
    expect(repositoryAddress).not.be.null;
  });
});
