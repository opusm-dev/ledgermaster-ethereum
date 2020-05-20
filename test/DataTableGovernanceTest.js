const { v4: uuid } = require('uuid');
const logger = require('./utils/logger.js');
const { createTable, addColumn, removeColumn, addIndex, removeIndex, addRow, updateRow, removeRow } = require('./utils/op.js');

const N_COLUMN = 6;
const N_REPEAT = 3;

contract('DataTableGovernance', (accounts) => {
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
    return createTable(tableName, keyColumnName).then(t => table = t);
  });

  it('test add / remove column', async () => {
    const columnNames = Array(N_COLUMN).fill().map(() => nameGen());
    await addColumn(table, ...columnNames);
    await removeColumn(table, ...columnNames);
  });

  it('test add / remove index', async () => {
    // Generate scenario
    const columnNames = Array(N_COLUMN).fill().map(() => nameGen());
    const nTry = Math.floor(Math.random() * columnNames.length);
    const indices = columnNames
      .filter(() => 0 == Math.floor(Math.random() * 3))
      .map(c => ({ name: nameGen(), column: c }));
    const indexColumnNames = indices.map(i => i.column);
    const indexNames = indices.map(i => i.name);

    // Execute scenario
    await addColumn(table, ...columnNames);

    await addIndex(table, ...indices);

    await removeIndex(table, ...indexNames);

    await removeColumn(table, ...columnNames);
  });
});
