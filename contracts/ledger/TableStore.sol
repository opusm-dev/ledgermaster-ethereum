pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

/* Interfaces */
import "../lib/system.sol";
import "../Table.sol";
import "./IndexFactory.sol";

/* Utilities */
import "../proxy/Controller.sol";
import "../proxy/Modules.sol";

contract TableStore is Controller, Modules {
  string[] TableNames;
  mapping(string => address) private Tables;

  /**
   * 테이블을 등록한다.
   */
  function registerTable(address _address) public onlyModulesGovernor {
    Table table = Table(_address);
    string memory tableName = table.getMetadata().name;
    require(utils.isNotEmpty(tableName));
    require(address(0x0) == Tables[tableName]);
    Tables[tableName] = _address;
    TableNames.push(tableName);
  }

  /**
   * 테이블을 등록해제한다.
   */
  function deregisterTable(string memory _name) public onlyModulesGovernor {
    require(address(0x0) != Tables[_name]);
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
