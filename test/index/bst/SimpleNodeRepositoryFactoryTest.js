const { v4: uuid } = require('uuid');
const { globalController, addNodeValue, removeNodeValue } = require('../../utils/op.js');
const modules = require('../../utils/modules.js');

const Controller = artifacts.require('Controller');
const StringComparator = artifacts.require('StringComparator');
const SimpleNodeRepository = artifacts.require('SimpleNodeRepository');
const SimpleNodeRepositoryFactory = artifacts.require('SimpleNodeRepositoryFactory');
const NodeRepository = artifacts.require('NodeRepository');

const N_NODE = 8;

contract('SimpleNodeRepositoryFactoryTest', (accounts) => {
  let repositoryFactory;
  let repository;

  beforeEach('', async () => {
    const controller = await globalController();
    repositoryFactory = await SimpleNodeRepositoryFactory.deployed();
    const tx = await repositoryFactory.create(controller.address, accounts[0]);
    const log = tx.receipt.logs[0];
    const repositoryAddress = log.args['addrezz'];
    repository = await SimpleNodeRepository.at(repositoryAddress);
    const c = await Controller.at(await repository.controller())
    c.setModule(modules.COMPARATOR, (await StringComparator.deployed()).address);
  });

  it('test set/get', async () => {
    const node = { kind: "0x01", key: uuid(), values: [], left: uuid(), right: uuid() };
    const tx = await repository.set(node);
    const stored = await repository.get(node.key);
    expect(stored.key).to.eq(node.key);
  });
  it('test remove', async () => {
    const key = uuid();
    const value = uuid();
    await repository.create(key);
    await repository.add(key, value);
    await repository.remove(key, value);
    const stored = await repository.get(key);
    expect(stored.key).to.eq(key);
    await repository.remove(key);
    const stored2 = await repository.get(key);
    expect(stored2.key).to.eq('');
  });
});
