const { v4: uuid } = require('uuid');
const { createTable, addColumn, addIndex, addRow } = require('./utils/op.js');
const logger = require('./utils/logger.js');
const modules = require('./utils/modules.js');
const RowRepository = artifacts.require('RowRepository');

contract('PSMLB-125', (accounts) => {
  let table;
  let repository;
  beforeEach('', async () => {
    table = await createTable(null, 'promotion', 'id');
    await addColumn(table, {name: 'address', type: 1});
    repository = await RowRepository.at(await table.getModule(modules.ROW_REPOSITORY));
  });

  it('simple', async () => {
    await addRow(table, { values: ['c2ceb24f-ea41-48f2-aca8-f59777ca5357', 'aaa'], available: true });
    const s = await repository.size();
    expect(s.toNumber()).to.eq(1);
    const rows = await table.findBy('id', { value: '', boundType: -1 }, { value: '', boundType: -1 }, 0);
    expect(rows.length).to.eql(1);
  });
});
