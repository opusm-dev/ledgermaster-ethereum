pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableRow.sol';

interface Constraint {
  function checkInsert(address sender, address store, string[] calldata row) external view returns (bool);
  function checkDelete(address sender, address store, string[] calldata row) external view returns (bool);
  function checkUpdate(address sender, address store, string[] calldata oldRow, string[] calldata newRow) external view returns (bool);
}
