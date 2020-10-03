const { v4: uuid } = require('uuid');
const StringComparator = artifacts.require('StringComparator');

contract('StringComparatorTest', (accounts) => {
  const N_REPEAT = 4;
  it('#compare', async () => {
    const stringComparator = await StringComparator.deployed();

    // Reflective
    for (let i = 0 ; i<N_REPEAT ; ++i) {
      const v = uuid();
      expect((await stringComparator.compare(v, v)).toNumber()).to.eq(0);
    }

    // Symmetric
    for (let i = 0 ; i<N_REPEAT ; ++i) {
      const v1 = uuid();
      const v2 = uuid();
      const c1 = (await stringComparator.compare(v1, v2)).toNumber()
      const c2 = (await stringComparator.compare(v2, v1)).toNumber()
      expect(c1).to.eq(c2 * -1);
    }

    // Transitive
    for (let i = 0 ; i<N_REPEAT ; ++i) {
      const v1 = uuid();
      const v2 = uuid();
      const v3 = uuid();
      const array = [v1, v2, v3];
      array.sort();

      const c1 = (await stringComparator.compare(array[0], array[1])).toNumber()
      const c2 = (await stringComparator.compare(array[1], array[2])).toNumber()
      const c3 = (await stringComparator.compare(array[0], array[2])).toNumber()
      expect(c1).to.eq(-1);
      expect(c2).to.eq(-1);
      expect(c3).to.eq(-1);
    }
  });
});
