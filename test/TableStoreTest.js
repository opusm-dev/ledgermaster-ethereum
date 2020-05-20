const { v4: uuid } = require('uuid');
const { createTable, registerTable, deregisterTable } = require('./utils/op.js');
const logger = require('./utils/logger.js');

const TableStore = artifacts.require('TableStore');

const N_TABLE = 6;
const N_REPEAT = 3;

contract('TableStore', (accounts) => {
  let tableStore;
  function nameGen() {
    const length = Math.random() * 5 + 3;
    return String.fromCharCode('a'.charCodeAt(0) + Math.floor(Math.random() * 26)) + uuid().substring(0, length);
  };

  function valueGen() {
    return uuid();
  };
  beforeEach('', () => {
    TableStore.new().then(ts => tableStore = ts);
  });

  it('test register / deregister table', async() => {
    const tables = Array(N_TABLE).fill().map(() => ({ name: nameGen(), column: nameGen() }));
    await Promise.all(tables.map(t => createTable(t.name, t.column)))
      .then(values => registerTable(tableStore, ...(values.map(table => table.address))));
    await deregisterTable(tableStore, ...tables.map(t => t.name));
  });

});
