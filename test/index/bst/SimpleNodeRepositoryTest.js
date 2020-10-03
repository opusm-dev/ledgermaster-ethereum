const { v4: uuid } = require('uuid');
const { createTree } = require('../../utils/op.js');


contract('SimpleNodeRepositoryTest', (accounts) => {
  let repository;
  beforeEach('', () => {
    return createTree(accounts[0])
      .then(all => {
        repository = all.repository;
      });
  });

  it('test set/get', async () => {
    const node = { kind: '0x01', key: uuid(), values: [], left: uuid(), right: uuid() };
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
