pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './RowRepository.sol';
import './DataTableState.sol';
import './DataTableVisitor.sol';
import './TableMetadata.sol';
import './Table.sol';

import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';
import '../common/proxy/Controlled.sol';

import '../index/Index.sol';
import './DataTableColumns.sol';
import './TableColumn.sol';
import './TableIndex.sol';

contract DataTable is DataTableState, Table, Controlled {
  /* General operations */
  string private constant ERR_ALREADY_INIT = 'ALREADY_INIT';
  string private constant ERR_ALREADY_EXIST = 'ALREADY_EXIST';
  string private constant ERR_NO_COLUMN = 'NO_COLUMN';
  string private constant ERR_NO_DATA = 'NO_DATA';
  string private constant ERR_DUPLICATED = 'DATA_DUPLICATED';
  string private constant ERR_UNAUTHORIZED = 'UNAUTHORIZED';

  /* Table status related error */
  string private constant ERR_ST_AVAILABLE = 'SHOULD_BE_AVAILABLE';

  /* Index-related error */
  string private constant ERR_INDEXED_COLUMN = 'CTR_INDEXED_COLUMN';

  /* Row-related error */
  string private constant ERR_KEY_VALUE_SIZE = 'KEY_VALUE_SIZE_NOT_MATCHED';
  string private constant ERR_INSERT_CONSTRAINT = 'INSERT_VIOLATION';
  string private constant ERR_UPDATE_CONSTRAINT = 'UPDATE_VIOLATION';
  string private constant ERR_DELETE_CONSTRAINT = 'DELETE_VIOLATION';

  address[] Friends;

  modifier statusAvailable {
    require(status == ST_AVAILABLE, ERR_ST_AVAILABLE);
    _;
  }

  constructor(address _controller) Controlled(_controller) public { }

  function requireAuthorized(address sender) private view {
    if (msg.sender != sender) {
      bool isFriend = false;
      for (uint i = 0 ; i<Friends.length ; ++i) {
        isFriend = isFriend || Friends[i] == msg.sender;
      }
      require(isFriend, ERR_UNAUTHORIZED);
    }
  }

  function initialize(address _store, string memory _name, string memory _keyColumnName, uint _keyColumnType) public override {
    store = _store;
    require(status == ST_CREATED, ERR_ALREADY_INIT);
    status = ST_INITIALIZING;
    name = _name;
    keyColumn = _keyColumnName;
    ColumnInput memory keyColumn = ColumnInput({
      name: _keyColumnName,
      dataType: _keyColumnType
    });
    addColumn(keyColumn);
    status = ST_AVAILABLE;
  }

  function getStore() public override returns (address) {
    return store;
  }

  function setStatus(int _status)
  public override onlyModulesGovernor {
    status = _status;
  }

  function getMetadata()
  public view override
  returns (TableMetadata memory) {
    return TableMetadata({
      name: name,
      keyColumn: keyColumn,
      location: address(this),
      columns: Columns,
      indices: Indices,
      rowRepository: getModule(ROW_REPOSITORY)
    });
  }

  function addFriend(address friend) public {
    Friends.push(friend);
  }

  /*********************************/
  /* Constraint-related governance */
  /*********************************/
  function addConstraint(address addrezz) public {
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('addConstraint(address)', addrezz));
    require(success, 'fail to add constraint');
  }

  function dropConstraint(address addrezz) public {
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('removeConstraint(address)', addrezz));
    require(success, 'fail to remove constraint');
  }

  /*****************************/
  /* Column-related governance */
  /*****************************/
  function addColumn(ColumnInput memory column) public {
    (bool success,) = getModule(PART_COLUMNS).delegatecall(abi.encodeWithSignature('addColumn(string,uint256)', column.name, column.dataType));
    require(success, 'fail to add a column');
  }
/*
  function dropColumn(string memory _name) public statusAvailable {
    (bool success,) = getModule(PART_COLUMNS).delegatecall(abi.encodeWithSignature('removeColumn(string)', _name));
    require(success, 'fail to remove a column');
  }
  */
  /****************************/
  /* Index-related governance */
  /****************************/
  function addIndex(IndexInput memory index) public {
    (bool success,) = getModule(PART_INDICES).delegatecall(abi.encodeWithSignature('addIndex(string,(string,uint256))', index.indexName, getColumn(index.columnName)));
    require(success, 'fail to add a index');
//    addIndex2(index.indexName, getColumn(index.columnName));
  }

  function addIndex2(string memory _name, TableColumn memory _column) public {
    require((status == ST_AVAILABLE) || (status == ST_INITIALIZING), 'Status must be ST_AVAILABLE or ST_INITIALIZING');
    // Add index
    for (uint i = 0 ; i<Indices.length ; ++i) {
      // Check index name duplication
      require(StringUtils.notEquals(Indices[i].indexName, _name), ERR_DUPLICATED);
      // Check column duplication
      require(StringUtils.notEquals(Indices[i].columnName, _column.name), ERR_INDEXED_COLUMN);
    }
    address indexAddress = createModule(INDEX_FACTORY);
    Controlled controlled = Controlled(indexAddress);
    address comparator = controlled.getModule(COMPARATOR + _column.dataType);
    controlled.controller().setModule(COMPARATOR, comparator);
    TableIndex memory tableIndex = TableIndex({ indexName: _name, columnName: _column.name, addrezz: indexAddress });
    Indices.push(tableIndex);
  }
/*

  function dropIndex(string memory _name) public statusAvailable {
    (bool success,) = getModule(PART_INDICES).delegatecall(abi.encodeWithSignature('removeIndex(string)', _name));
    require(success, 'fail to remove a index');
  }
  */
  /**
   * Status 확인은 public에서 미리 확인하도록 함
   */
  function addIndexFor(TableRow memory row) private {
    // Row key
    string memory key = getColumnValue(row, keyColumn);
    // iterate indices
    for (uint i = 0 ; i < Indices.length ; ++i) {
      // For each index
      string memory columnName = Indices[i].columnName;
      Index index = Index(Indices[i].addrezz);
      index.add(getColumnValue(row, columnName), key);
    }
  }
  /**
   * Status 확인은 public에서 미리 확인하도록 함
   */
  function removeIndexFor(TableRow memory row) private {
    // Row key
    string memory key = getColumnValue(row, keyColumn);
    // iterate indices
    for (uint i = 0 ; i < Indices.length ; ++i) {
      // For each index
      string memory columnName = Indices[i].columnName;
      Index index = Index(Indices[i].addrezz);
      index.remove(getColumnValue(row, columnName), key);
    }
  }
  /**************************/
  /* Row-related governance */
  /**************************/
  function add(TableRow memory row) public statusAvailable {
    add(msg.sender, row);
  }

  function remove(string memory key) public statusAvailable {
    remove(msg.sender, key);
  }

  function update(TableRow memory newRow) public statusAvailable {
    update(msg.sender, newRow);
  }

  function add(address sender, TableRow memory row) public statusAvailable {
    requireAuthorized(sender);
    string memory key = getColumnValue(row, keyColumn);
    require(row.names.length == row.values.length, ERR_KEY_VALUE_SIZE);
    require(!getRow(key).available, ERR_ALREADY_EXIST);
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkInsert(address,(string[],string[],bool))', sender, row));
    require(success, ERR_INSERT_CONSTRAINT);
    RowRepository(getModule(ROW_REPOSITORY)).set(key, row);
    addIndexFor(row);
  }

  function remove(address sender, string memory key) public statusAvailable {
    requireAuthorized(sender);
    // Check if it exists
    TableRow memory row = getRow(key);
    require(row.available, ERR_NO_DATA);
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkDelete(address,(string[],string[],bool))', sender, row));
    require(success, ERR_DELETE_CONSTRAINT);
    removeIndexFor(row);
    RowRepository(getModule(ROW_REPOSITORY)).remove(key);
  }

  function update(address sender, TableRow memory newRow) public statusAvailable {
    requireAuthorized(sender);
    require(newRow.names.length == newRow.values.length, ERR_KEY_VALUE_SIZE);
    string memory key = getColumnValue(newRow, keyColumn);
    TableRow memory oldRow = getRow(key);
    require(oldRow.available, ERR_NO_DATA);
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkUpdate(address,(string[],string[],bool),(string[],string[],bool))', sender, oldRow, newRow));
    require(success, ERR_UPDATE_CONSTRAINT);
    for (uint i = 0 ; i < Indices.length ; ++i) {
      // For each index
      string memory columnName = Indices[i].columnName;
      string memory oldColumn = getColumnValue(oldRow, columnName);
      string memory newColumn = getColumnValue(newRow, columnName);
      if (StringUtils.notEquals(oldColumn, newColumn)) {
        Index index = Index(Indices[i].addrezz);
        index.remove(oldColumn, key);
        index.add(newColumn, key);
      }
    }
    RowRepository(getModule(ROW_REPOSITORY)).set(key, newRow);
  }

  function getRow(string memory key) public view statusAvailable returns (TableRow memory) {
    return RowRepository(getModule(ROW_REPOSITORY)).get(key);
  }

  /**
   * point type:
   * -1 - unbound
   * 0 - Included bound
   * 1 - Excluded bound
   * _orderType
   * -1 : 내림차순 정렬
   * 0 : 정렬 없음
   * 1 : 오름차순 정렬
   */
  function findBy(string calldata _column, ValuePoint calldata _start, ValuePoint calldata _end, int _orderType)
  external view statusAvailable
  returns (TableRow[] memory) {
    TableVisitor visitor = TableVisitor(getModule(TABLE_VISITOR));
    return visitor.findBy(this, _column, _start, _end, _orderType);
  }

  function countBy(string calldata _column, ValuePoint calldata _start, ValuePoint calldata _end)
  external view statusAvailable
  returns (uint) {
    TableVisitor visitor = TableVisitor(getModule(TABLE_VISITOR));
    return visitor.countBy(this, _column, _start, _end);
  }

  /* Library */
  function getColumn(string memory columnName) internal view returns (TableColumn memory) {
    for (uint i = 0 ; i < Columns.length ; ++i) {
      if (StringUtils.equals(Columns[i].name, columnName)) {
        return Columns[i];
      }
    }
    require(false, ERR_NO_COLUMN);
  }
  function getColumnValue(TableRow memory row, string memory columnName) internal pure returns (string memory) {
    for (uint i = 0 ; i < row.names.length ; ++i) {
      if (StringUtils.equals(row.names[i], columnName)) {
        return row.values[i];
      }
    }
    return '';
  }
}
