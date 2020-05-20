const uuid = require('uuid').v1;
const { createTree } = require('./utils/op.js');


contract('SimpleNodeRepository', (accounts) => {
  let repository;
  beforeEach('', () => {
    return createTree()
      .then(all => {
        repository = all.repository;
      });
  });

  it('test set/get', async () => {
    const node = { kind: '0x01', key: uuid(), values: [], left: uuid(), right: uuid() };
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
