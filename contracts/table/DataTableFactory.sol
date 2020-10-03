pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './DataTable.sol';

import '../Modules.sol';
import '../common/proxy/Controlled.sol';
import '../common/proxy/ContractFactory.sol';
import '../common/proxy/ModuleController.sol';

contract DataTableFactory is ContractFactory, Modules {
  event NewTable(address addrezz);
  function create(address _controller, address owner) public override returns (address) {
    DataTable table = new DataTable(_controller);
    table.changeOwner(owner);
    address addrezz = address(table);
    emit NewTable(addrezz);
    return addrezz;
  }
}
