const { v4: uuid } = require('uuid');
const IntegerComparator = artifacts.require('IntegerComparator');

contract('IntegerComparatorTest', (accounts) => {
  const N_REPEAT = 4;
  it('#compare', async () => {
    const integerComparator = await IntegerComparator.deployed();
    for (let i = 0 ; i<N_REPEAT ; ++i) {
      const i1 = Math.floor(Math.random(10)) - 5;
      const i2 = Math.floor(Math.random(10)) - 5;
      const c1 = (await integerComparator.compare(i1.toString(), i2.toString())).toNumber();
      const c2 = (await integerComparator.compare(i2.toString(), i1.toString())).toNumber();
      expect(c1 + c2).to.eq(0);
    }
  });
});
