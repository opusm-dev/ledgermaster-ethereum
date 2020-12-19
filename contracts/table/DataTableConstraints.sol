pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './TableRow.sol';
import './Constraint.sol';
import './DataTableState.sol';

contract DataTableConstraints is DataTableState {
  /* General operations */
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_DATA_TABLE_CONSTRAINTS';
  string private constant ERR_ALREADY_EXIST = 'ALREADY_EXIST_CONSTRAINT';
  string private constant ERR_NO_CONSTRAINT = 'NO_CONSTRAINT';
  string private constant ERR_CONSTRAINTS = 'CONSTRAINT_VIOLATION';

  /*********************************/
  /* Constraint-related governance */
  /*********************************/
  function addConstraint(address addrezz) public {
    for (uint i = 0 ; i < Constraints.length ; ++i) {
      require(Constraints[i] != addrezz, ERR_ALREADY_EXIST);
    }
    Constraints.push(addrezz);
  }

  function removeConstraint(address addrezz) public {
    uint deletionCount = 0;
    uint beforeColumns = Constraints.length;
    for (uint i = 0 ; i<Constraints.length ; ++i ) {
      uint index = uint(i - deletionCount);
      if (Constraints[index] == addrezz) {
        Constraints[index] = Constraints[Constraints.length - 1];
        Constraints.pop();
        ++deletionCount;
        --i;
      }
    }
    // Check if column deleted
    require(1 == deletionCount, ERR_NO_CONSTRAINT);
    // Check if column size decreased
    require(beforeColumns - deletionCount == Constraints.length, ERR_ILLEGAL);
  }

  function checkInsert(address sender, string[] memory row) public view {
    for (uint i = 0 ; i < Constraints.length ; ++i) {
      require(Constraint(Constraints[i]).checkInsert(sender, store, row), ERR_CONSTRAINTS);
    }
  }

  function checkDelete(address sender, string[] memory row) public view {
    for (uint i = 0 ; i < Constraints.length ; ++i) {
      require(Constraint(Constraints[i]).checkDelete(sender, store, row), ERR_CONSTRAINTS);
    }
  }

  function checkUpdate(address sender, string[] memory oldRow, string[] memory newRow) public view {
    for (uint i = 0 ; i < Constraints.length ; ++i) {
      require(Constraint(Constraints[i]).checkUpdate(sender, store, oldRow, newRow), ERR_CONSTRAINTS);
    }
  }
}
