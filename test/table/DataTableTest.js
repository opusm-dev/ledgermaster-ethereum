const { v4: uuid } = require('uuid');
const { createTable, addColumn, addIndex, addRow, updateRow, removeRow } = require('../utils/op.js');
const logger = require('../utils/logger.js');

const N_COLUMN = 6;
const N_ROW = 8;
const N_REPEAT = 4;

contract('DataTableTest', (accounts) => {
  let table;
  let keyColumnName;
  function nameGen() {
    const length = Math.random() * 5 + 3;
    return String.fromCharCode('a'.charCodeAt(0) + Math.floor(Math.random() * 26)) + uuid().substring(0, length);
  };

  function valueGen() {
    return uuid().substring(0, 8);
  };

  beforeEach('', () => {
    const tableName = nameGen();
    keyColumnName = nameGen();
    return createTable(null,  tableName, keyColumnName).then(t => table = t);
  });

  it('#getRow', async() => {
    const keyColumnValue = uuid();
    await addRow(table, { names: [keyColumnName], values: [keyColumnValue] });
    const row = await table.getRow(keyColumnValue);
    expect(row['available']).to.equal(true);
  });

  it('#findBy: with index', async () => {
    const keyColumnValue = uuid();
    await addColumn(table, {name: 'parent', type: 1});
    await addIndex(table, { name: 'idx_parent', column: 'parent' });
    await addRow(table, { names: [keyColumnName, 'parent'], values: [keyColumnValue, ''] });
    const children = await table.findBy('parent', { value: keyColumnValue, boundType: 0 }, { value: keyColumnValue, boundType: 0 }, 1);
    expect(children.length).to.eq(0);
  });

  it('#findBy: without index', async () => {
    const keyColumnValue = uuid();
    await addColumn(table, {name: 'parent', type: 1});
    await addRow(table, { names: [keyColumnName, 'parent'], values: [keyColumnValue, ''] });
    const children = await table.findBy('parent', { value: keyColumnValue, boundType: 0 }, { value: keyColumnValue, boundType: 0 }, 1);
    expect(children.length).to.eq(0);
  });

  it ('#findBy: sort by string / integer', async () => {
    await addColumn(table, {name: 'string_column', type: 1})
    await addColumn(table, {name: 'integer_column', type: 2})
    await addIndex(table, { name: 'idx_string', column: 'string_column' })
    await addIndex(table, { name: 'idx_integer', column: 'integer_column' })
    const names = [keyColumnName, 'string_column', 'integer_column'];

    for (let i = 0 ; i<N_ROW ; ++i) {
      const v = Math.floor((Math.random() * 10000) - 500).toString()
      await addRow(table, { names, values: [uuid(), v, v] });
    }

    const stringSorted = await table.findBy('string_column', { value: '', boundType: -1 }, { value: '', boundType: -1 }, 1);
    for (let i = 0 ; i < stringSorted.length - 1 ; ++i) {
      expect(stringSorted[i][1][2].localeCompare(stringSorted[i+1][1][2])).to.eq(-1);
    }


    const integerSorted = await table.findBy('integer_column', { value: '', boundType: -1 }, { value: '', boundType: -1 }, 1);
    for (let i = 0 ; i < integerSorted.length - 1 ; ++i) {
      expect(integerSorted[i][1][2].toNumber() < integerSorted[i+1][1][2].toNumber()).to.eq(true);
    }
  });


  it('#add / #remove / #update / #findBy', async() => {
    const columnNames = Array(N_COLUMN).fill().map(() => nameGen());
    const columns = columnNames.map((name) => ({name: name, type: 1}));
    const indices = columnNames
      .filter(() => 0 == Math.floor(Math.random() * 3))
      .map(name => ({ name: nameGen(), column: name }));

    // Execute scenario
    await addColumn(table, ...columns);
    await addIndex(table, ...indices);

    const allColumnNames = [keyColumnName].concat(columnNames);
    const rows = Array(N_ROW).fill()
      .map(() => ({ names: allColumnNames, values: allColumnNames.map(it => valueGen()) }));
    await addRow(table, ...rows);

    function testFindBy() {
      const r1 = Math.floor(Math.random() * rows.length);
      const r2 = Math.floor(Math.random() * rows.length);
      const c = Math.floor(Math.random() * allColumnNames.length);
      const columnName = allColumnNames[c];

      const c1 = rows[r1].values[c];
      const c2 = rows[r2].values[c];

      const start = (c1.localeCompare(c2) < 0)?c1:c2
      const end = (c1.localeCompare(c2) >= 0)?c1:c2

      const startType = Math.floor(3 * Math.random()) - 1;
      const endType = Math.floor(3 * Math.random()) - 1;
      const orderType = Math.floor(3 * Math.random()) - 1;

      // Input expression
      const startSymbol = (0 == startType)?'[':'(';
      const startStr = (-1 == startType)?'oo':start.toString();
      const endSymbol = (0 == endType)?']':')';
      const endStr = (-1 == endType)?'oo':end.toString();
      const input = startSymbol + startStr + ',' + endStr + endSymbol + ':' + orderType;

      logger.action('Find ' + columnName + ' in ' + input);

      function getValue(row, name) {
        const columnIndex = row[0].indexOf(name);
        if (columnIndex < 0) {
          console.log('Row:', row);
          console.log('Name:', name);
        }
        expect(columnIndex).to.be.at.least(0, 'Row\'s ' + name + ': ' + row.toString());
        return row[1][columnIndex];
      }
      return table.findBy(columnName, { value: start, boundType: startType }, { value: end, boundType: endType }, orderType)
        .then(list => {
          const values = list.map(row => getValue(row, columnName))
          function stringCompare(a, b) {
            const min = Math.min(a, b);
            for (let i=0 ; i<min ; ++i) {
              if (a.charCodeAt(i) > b.charCodeAt(i)) {
                return 1;
              } else if (a.charCodeAt(i) < b.charCodeAt(i)) {
                return -1;
              }
            }
            return a.least - b.least;
          }

          function checkBound(v) {
            return (-1 == startType || stringCompare(start, v) < 0 || (0 == startType && stringCompare(start, v) == 0)) &&
              (-1 == endType || stringCompare(end, v) > 0 || (0 == endType && stringCompare(end, v) == 0));
          }
          expect(values.every(v => checkBound)).to.be.eq(true, input + ' list:' + values.toString());
          if (-1 == orderType) {
            // Descending sort
            expect(values).to.be.eql(values.slice().sort().reverse(), input + ' list:' + values.toString());
          } else if (1 == orderType) {
            // Ascending sort
            expect(values).to.be.eql(values.slice().sort(), input + ' list:' + values.toString());
          }
        });
    }

    await Promise.all(Array(N_REPEAT).fill(0).map(() => testFindBy()));

    const rowsToUpdate = rows.filter(() => 0 == Math.floor(Math.random() * 3))
      .map(row => ({ names: row.names, values: row.values.map((v, i) => (0==i)?v:valueGen()) }));

    await updateRow(table, ...rowsToUpdate);

    await removeRow(table, ...rows.map(row => row.values[0]));
  });

});
