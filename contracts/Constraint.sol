pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './lib/tab.sol';

interface Constraint {
  function checkInsert(address sender, address store, table.Row calldata row) external view returns (bool);
  function checkDelete(address sender, address store, table.Row calldata row) external view returns (bool);
  function checkUpdate(address sender, address store, table.Row calldata oldRow, table.Row calldata newRow) external view returns (bool);
}
