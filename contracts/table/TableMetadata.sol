pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableColumn.sol';
import './TableIndex.sol';

struct TableMetadata {
  string name;
  address location;
  TableColumn[] columns;
  TableIndex[] indices;
  address rowRepository;
}
