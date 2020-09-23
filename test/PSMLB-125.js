const { v4: uuid } = require('uuid');
const { createTable, addColumn, addIndex, addRow } = require('./utils/op.js');
const logger = require('./utils/logger.js');

contract('PSMLB-125', (accounts) => {
  it('simple', () => {
    return createTable(null, 'promotion', 'id')
      .then(t => addColumn(t, 'address')
        .then(() => addRow(t, { names: ['id', 'address'], values: ['c2ceb24f-ea41-48f2-aca8-f59777ca5357', 'aaa'], available: true }))
        .then(() => t.findBy('id', { value: '', boundType: -1 }, { value: '', boundType: -1 }, 0))
        .then((rows) => console.log('Promotions: ', rows)));
  });
});
