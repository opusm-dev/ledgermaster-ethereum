const { v4: uuid } = require('uuid');
const { createTable, addColumn, addIndex, addRow, updateRow, removeRow } = require('./utils/op.js');
const logger = require('./utils/logger.js');

const N_COLUMN = 6;
const N_REPEAT = 10;

contract('DataTable', (accounts) => {
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

  it('get row', async() => {
    return table.add({names: [keyColumnName], values: ['0x176b615d4e826429504a18d6eb8a2eaba86e5de7']})
      .then(() => table.findBy(keyColumnName, { value: '0x176b615d4e826429504a18d6eb8a2eaba86e5de7', boundType: 0 }, { value: '0x176b615d4e826429504a18d6eb8a2eaba86e5de7', boundType: 0 }, 0).then((it) => expect(it[0][2]).to.equal(true)));
  });

  it('test add / remove / update / findBy', async() => {
    const columnNames = Array(N_COLUMN).fill().map(() => nameGen());
    const indices = columnNames
      .filter(() => 0 == Math.floor(Math.random() * 3))
      .map(c => ({ name: nameGen(), column: c }));

    // Execute scenario
    await addColumn(table, ...columnNames);

    await addIndex(table, ...indices);

    const allColumnNames = [keyColumnName].concat(columnNames);
    const rows = Array(6).fill()
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

  it('case 1', () => {
    return createTable(null, 'certificate', 'id')
      .then(t => addColumn(t, 'parent')
        .then(() => t.addIndex('idx_parent', 'parent'))
        .then(() => addRow(t, { names: ['id', 'parent'], values: ['c2ceb24f-ea41-48f2-aca8-f59777ca5357', ''], available: true }))
        .then(() => t.findBy('id', { value: 'c2ceb24f-ea41-48f2-aca8-f59777ca5357', boundType: 0 }, { value: 'c2ceb24f-ea41-48f2-aca8-f59777ca5357', boundType: 0 }, 0))
        .then(() => t.findBy('parent', { value: 'c2ceb24f-ea41-48f2-aca8-f59777ca5357', boundType: 0 }, { value: 'c2ceb24f-ea41-48f2-aca8-f59777ca5357', boundType: 0 }, 1)));
  });

});
