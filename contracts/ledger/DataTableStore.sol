pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Interfaces */
import "../lib/system.sol";
import "../Table.sol";
import "./IndexFactory.sol";

/* Utilities */
import "../proxy/Controller.sol";
import "../proxy/Modules.sol";

contract DataTableStore is Controller, Modules {
  string private constant ERR_NO_TABLE = "NO_TABLE";
  string private constant ERR_TABLE_NAME = "INVALID_TABLE_NAME";
  string private constant ERR_ALREADY_EXISTS = "ALREADY_EXISTS";


  string[] TableNames;
  mapping(string => address) private Tables;

  /**
   * 테이블을 등록한다.
   */
  function registerTable(address _address) public onlyModulesGovernor {
    Table table = Table(_address);
    string memory tableName = table.getMetadata().name;
    require(utils.isNotEmpty(tableName), ERR_TABLE_NAME);
    require(address(0x0) == Tables[tableName], ERR_ALREADY_EXISTS);
    Tables[tableName] = _address;
    TableNames.push(tableName);
  }

  /**
   * 테이블을 등록해제한다.
   */
  function deregisterTable(string memory _name) public onlyModulesGovernor {
    require(address(0x0) != Tables[_name], ERR_NO_TABLE);
    delete Tables[_name];
    for (uint i=0 ; i<TableNames.length ; ++i) {
      if (utils.equals(TableNames[i], _name)) {
        TableNames[i] = TableNames[TableNames.length -1];
        TableNames.pop();
        --i;
      }
    }
  }

  /**
   * 테이블 이를들을 반환한다.
   */
  function listTableNames() public view returns (string[] memory) {
    return TableNames;
  }

  /**
   * 테이블 정보를 반환한다.
   */
  function getTable(string memory _tableName) public view returns (address) {
    return Tables[_tableName];
  }
}
