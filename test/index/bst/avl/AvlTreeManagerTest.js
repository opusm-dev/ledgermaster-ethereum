const { v4: uuid } = require('uuid');
const modules = require('../../../utils/modules.js');
const { getAvlTreeManager, createTree, addNodeValue, removeNodeValue } = require('../../../utils/op.js');

const NodeRepository = artifacts.require('NodeRepository');

const N_NODE = 8;

contract('AvlTreeManagerTest', (accounts) => {
  let tree;
  let repository;
  let manager

  beforeEach('', async () => {
    const all = await createTree(accounts[0])
    tree = all.tree;
    repository = all.repository;
    manager = await getAvlTreeManager();
  });

  it('test remove', async () => {
    await manager.add(repository.address, '2', '2');
    await manager.add(repository.address, '1', '1');
    await manager.add(repository.address, '3', '3');
    expect((await repository.get('1')).kind).to.not.eq('0x00')
    expect((await repository.get('2')).kind).to.not.eq('0x00')
    expect((await repository.get('3')).kind).to.not.eq('0x00')
    await manager.remove(repository.address, '1', '1');
    await manager.remove(repository.address, '2', '2');
    await manager.remove(repository.address, '3', '3');
    expect((await repository.get('1')).kind).to.eq('0x00')
    expect((await repository.get('2')).kind).to.eq('0x00')
    expect((await repository.get('3')).kind).to.eq('0x00')
  });
});
