const { v4: uuid } = require('uuid');
const logger = require('../utils/logger.js');
const { createStore, createTable, registerTable, deregisterTable } = require('../utils/op.js');

const N_COLUMN = 4;
const N_TABLE = 3;
const N_REPEAT = 3;

contract('DataTableStoreTest', (accounts) => {
  let store;
  let table;
  let keyColumnName;
  function nameGen() {
    const length = Math.random() * 5 + 3;
    return String.fromCharCode('a'.charCodeAt(0) + Math.floor(Math.random() * 26)) + uuid().substring(0, length);
  };

  function valueGen() {
    return uuid();
  };

  beforeEach('', () => {
    const tableName = nameGen();
    keyColumnName = nameGen();
    return createStore().then(it => store = it);
  });

  it('create table', async () => {
    const name = nameGen();
    await store.createTable(name, nameGen(), 1);
    const t = await store.getTable(name);
    console.log('Table', t);
  });

  it('test register / deregister table', async () => {
    const tables = Array(N_TABLE).fill().map(() => ({ name: nameGen(), column: nameGen() }));
    await Promise.all(tables.map(t => createTable(store, t.name, t.column)))
      .then(values => registerTable(store, ...(values.map(table => table.address))));
    await deregisterTable(store, ...tables.map(t => t.name));
  });

});
