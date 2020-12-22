pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Table.sol';

import '../common/StringUtils.sol';
import '../common/proxy/Controlled.sol';
import '../common/proxy/ModuleController.sol';

contract DataTableStore is Controlled {
  string private constant ERR_NO_TABLE = 'NO_TABLE';
  string private constant ERR_TABLE_NAME = 'INVALID_TABLE_NAME';
  string private constant ERR_ALREADY_EXISTS = 'ALREADY_EXISTS';

  string[] TableNames;
  mapping(string => address) private Tables;

  constructor(address _controller) Controlled(_controller) public { }

  function createTable(string memory _name, string memory _keyColumnName, uint _keyColumnType) public onlyModulesGovernor {
    ModuleController tableController = new ModuleController();
    tableController.setModule(STRING_COMPARATOR, controller.getModule(STRING_COMPARATOR));
    tableController.setModule(INTEGER_COMPARATOR, controller.getModule(INTEGER_COMPARATOR));
    tableController.setModule(MIN_FINDER, controller.getModule(MIN_FINDER));
    tableController.setModule(NODE_FINDER, controller.getModule(NODE_FINDER));

    tableController.setModule(PART_CONSTRAINTS, controller.getModule(PART_CONSTRAINTS));
    tableController.setModule(PART_COLUMNS, controller.getModule(PART_COLUMNS));
    tableController.setModule(PART_INDICES, controller.getModule(PART_INDICES));

    tableController.setModule(BALANCER, controller.getModule(BALANCER));
    tableController.setModule(VISITOR, controller.getModule(VISITOR));
    tableController.setModule(TABLE_VISITOR, controller.getModule(TABLE_VISITOR));
    tableController.setModule(MANAGER, controller.getModule(MANAGER));

    tableController.setModule(NODE_REPOSITORY_FACTORY, controller.getModule(NODE_REPOSITORY_FACTORY));
    tableController.setModule(TABLE_FACTORY, controller.getModule(TABLE_FACTORY));
    tableController.setModule(HASH_INDEX_FACTORY, controller.getModule(HASH_INDEX_FACTORY));
    tableController.setModule(SORT_INDEX_FACTORY, controller.getModule(SORT_INDEX_FACTORY));

    address tableAddress = tableController.createModule(address(tableController), TABLE_FACTORY);
    Table table = Table(tableAddress);
    table.initialize(address(this), _name, _keyColumnName, _keyColumnType);
    registerTable(tableAddress);
  }

  /**
   * 테이블을 등록한다.
   */
  function registerTable(address _address) public onlyModulesGovernor {
    Table table = Table(_address);
    string memory tableName = table.getMetadata().name;
    require(StringUtils.isNotEmpty(tableName), ERR_TABLE_NAME);
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
      if (StringUtils.equals(TableNames[i], _name)) {
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
