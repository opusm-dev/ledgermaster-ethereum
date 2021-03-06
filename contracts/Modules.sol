pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

contract Modules {
  /* Common */
  uint internal constant COMPARATOR = 1000;
  uint internal constant STRING_COMPARATOR = 1001;
  uint internal constant INTEGER_COMPARATOR = 1002;

  /* In TableStore */
  uint internal constant TABLE_FACTORY = 100;

  /* In table */
  uint internal constant NODE_REPOSITORY_FACTORY = 201;
  uint internal constant HASH_INDEX_FACTORY = 204;
  uint internal constant SORT_INDEX_FACTORY = 205;
  uint internal constant PART_CONSTRAINTS = 230;
  uint internal constant PART_COLUMNS = 231;
  uint internal constant PART_INDICES = 232;

  /* In Avl Tree */
  uint internal constant NODE_REPOSITORY = 300;
  uint internal constant MIN_FINDER = 301;
  uint internal constant NODE_FINDER = 302;
  uint internal constant BALANCER = 310;
  uint internal constant VISITOR = 320;
  uint internal constant TABLE_VISITOR = 321;
  uint internal constant MANAGER = 330;
}
