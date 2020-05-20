const { v4: uuid } = require('uuid');
const { addNodeValue, removeNodeValue } = require('./utils/op.js');

const SimpleNodeRepositoryFactory = artifacts.require('SimpleNodeRepositoryFactory');
const NodeRepository = artifacts.require('NodeRepository');

const N_NODE = 8;

contract('SimpleNodeRepositoryFactory', (accounts) => {
  let repository;

  beforeEach('', () => {
    const key = uuid();
    return SimpleNodeRepositoryFactory.new()
      .then(f => f.create(key).then(() => f.get(key)))
      .then(address => NodeRepository.at(address))
      .then(r => repository = r);
  });

  it('test set/get', async () => {
    const node = { kind: "0x01", key: uuid(), values: [], left: uuid(), right: uuid() };
    const tx = await repository.set(node);
    const stored = await repository.get(node.key);
    assert.equal(stored.key, node.key);
  });
  it('test remove', async () => {
    const key = uuid();
    const value = uuid();
    await repository.create(key);
    await repository.add(key, value);
    await repository.remove(key, value);
    const stored = await repository.get(key);
    assert.equal(stored.key, key);
    await repository.remove(key);
    const stored2 = await repository.get(key);
    assert.equal(stored2.key, '');
  });
});
