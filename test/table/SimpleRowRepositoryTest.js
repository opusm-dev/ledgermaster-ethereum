const { v4: uuid } = require('uuid');
const { createRowRepository, addColumn, addIndex, addRow, updateRow, removeRow } = require('../utils/op.js');
const logger = require('../utils/logger.js');

const N_COLUMN = 6;
const N_ROW = 8;
const N_REPEAT = 4;

contract('SimpleRowRepositoryTest', (accounts) => {
  let repository;
  function nameGen() {
    const length = Math.random() * 5 + 3;
    return String.fromCharCode('a'.charCodeAt(0) + Math.floor(Math.random() * 26)) + uuid().substring(0, length);
  };

  function valueGen() {
    return uuid().substring(0, 8);
  };

  beforeEach('', async () => {
    return repository = await createRowRepository();
  });

  it('#set', async () => {
    const key = nameGen();
    await repository.set(key, {names: [key], values: [valueGen()]});
    const row = await repository.get(key);
    expect(row.available).to.eq(true);
  });

  it('#findBy', async () => {
    const key = nameGen();
    await repository.set(key, {names: [key], values: [valueGen()]});
    const rows = await repository.findBy({ name: key, dataType: 1}, { value: '', boundType: -1 }, { value: '', boundType: -1 }, 0);
    console.log('Rows:', rows);
    expect(rows.length).to.eq(1);
  });

});
