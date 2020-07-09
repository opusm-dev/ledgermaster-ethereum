pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "../lib/system.sol";
import "../lib/tab.sol";
import "../proxy/Controller.sol";
import "../proxy/Modules.sol";

import "../Index.sol";
import "../Table.sol";
import "../RowRepository.sol";

import "./DataTableState.sol";

contract DataTable is DataTableState, Table, Controller, Modules {
  /* General operations */
  string private constant ERR_ILLEGAL = "ILLEGAL_STATE";
  string private constant ERR_ALREADY_EXIST = "ALREADY_EXIST";
  string private constant ERR_NO_DATA = "NO_DATA";
  string private constant ERR_DUPLICATED = "DATA_DUPLICATED";
  string private constant ERR_UNAUTHORIZED = "UNAUTHORIZED";

  /* Table status related error */
  string private constant ERR_ST_AVAILABLE = "SHOULD_BE_AVAILABLE";

  /* Column-related error */
  string private constant ERR_INVALID_COLUMN = "INVALID_COLUMN";

  /* Index-related error */
  string private constant ERR_INDEXED_COLUMN = "CTR_INDEXED_COLUMN";

  /* Row-related error */
  string private constant ERR_KEY_VALUE_SIZE = "KEY_VALUE_SIZE_NOT_MATCHED";
  string private constant ERR_CONSTRAINTS = "CONSTRAINT_VIOLATION";

  address[] Friends;

  modifier statusAvailable {
    require(status == ST_AVAILABLE, ERR_ST_AVAILABLE);
    _;
  }

  function requireAuthorized(address sender) private view {
    if (msg.sender != sender) {
      bool isFriend = false;
      for (uint i = 0 ; i<Friends.length ; ++i) {
        isFriend = isFriend || Friends[i] == msg.sender;
      }
      require(isFriend, ERR_UNAUTHORIZED);
    }
  }

  function initialize(address _store, string memory _name, string memory _keyColumn, int _keyColumnType)
  public override {
    store = _store;
    require(status == ST_CREATED, "Already initialized");
    status = ST_INITIALIZING;
    name = _name;
    keyColumn = _keyColumn;
    addColumn(_keyColumn, _keyColumnType);
    addIndex(name, keyColumn);
    require(status == ST_INITIALIZING);
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
  returns (table.TableMetadata memory) {
    return table.TableMetadata({
      name: name,
      keyColumn: keyColumn,
      location: address(this),
      columns: Columns,
      indices: Indices
    });
  }

  function addFriend(address friend) public {
    Friends.push(friend);
  }

  /**************/
  /* Delegation */
  /**************/
  function rowRepository() private view returns(RowRepository) {
    address addrezz = getModule(ROW_REPOSITORY);
    return RowRepository(addrezz);
  }

  /*********************************/
  /* Constraint-related governance */
  /*********************************/
  function addConstraint(address addrezz) public {
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('addConstraint(address)', addrezz));
    require(success, 'fail to add constraint');
  }

  function removeConstraint(address addrezz) public {
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('removeConstraint(address)', addrezz));
    require(success, 'fail to remove constraint');
  }

  /*****************************/
  /* Column-related governance */
  /*****************************/
  function addColumn(string memory _name, int256 _type) public {
    (bool success,) = getModule(PART_COLUMNS).delegatecall(abi.encodeWithSignature('addColumn(string,int256)', _name, _type));
    require(success, 'fail to add a column');
  }

  function removeColumn(string memory _name) public statusAvailable {
    (bool success,) = getModule(PART_COLUMNS).delegatecall(abi.encodeWithSignature('removeColumn(string)', _name));
    require(success, 'fail to remove a column');
  }

  /****************************/
  /* Index-related governance */
  /****************************/
  function addIndex(string memory _name, string memory _column) public {
    require((status == ST_AVAILABLE) || (status == ST_INITIALIZING), "Status must be ST_AVAILABLE or ST_INITIALIZING");
    // Add index
    for (uint i = 0 ; i<Indices.length ; ++i) {
      // Check index name duplication
      require(utils.notEquals(Indices[i].indexName, _name), ERR_DUPLICATED);
      // Check column duplication
      require(utils.notEquals(Indices[i].columnName, _column), ERR_INDEXED_COLUMN);
    }

    address indexAddress = createModule(INDEX_FACTORY, _name);
    Indices.push(table.Index({ indexName: _name, columnName: _column, addrezz: indexAddress }));
  }

  function removeIndex(string memory _name) public statusAvailable {
    // Drop index
    uint deletionCount = 0;
    uint beforeIndices = Indices.length;
    require(utils.notEquals(_name, name), "Should not remove key index");
    for (uint i = 0 ; i<Indices.length ; ++i ) {
      uint index = uint(i - deletionCount);
      if (utils.equals(Indices[index].indexName, _name)) {
        Indices[index] = Indices[Indices.length - 1];
        Indices.pop();
        ++deletionCount;
        --i;
      }
    }
    // Check if index deleted
    require(1 == deletionCount, ERR_NO_DATA);
    // Check if index size decreased
    require(beforeIndices - deletionCount == Indices.length, ERR_ILLEGAL);
  }

  /**
   * Status 확인은 public에서 미리 확인하도록 함
   */
  function addIndexFor(table.Row memory row) private {
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
  function removeIndexFor(table.Row memory row) private {
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
  function addRow(table.Row memory row) public statusAvailable {
    addRow(msg.sender, row);
  }

  function removeRow(string memory key) public statusAvailable {
    removeRow(msg.sender, key);
  }

  function updateRow(table.Row memory newRow) public statusAvailable {
    updateRow(msg.sender, newRow);
  }

  function addRow(address sender, table.Row memory row) public statusAvailable {
    requireAuthorized(sender);
    string memory key = getColumnValue(row, keyColumn);
    require(row.names.length == row.values.length, ERR_KEY_VALUE_SIZE);
    require(!getRow(key).available, ERR_ALREADY_EXIST);
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkInsert(address,(string[],string[],bool))', sender, row));
    require(success, ERR_CONSTRAINTS);
    rowRepository().set(key, row);
    addIndexFor(row);
  }

  function removeRow(address sender, string memory key) public statusAvailable {
    requireAuthorized(sender);
    // Check if it exists
    table.Row memory row = getRow(key);
    require(row.available, ERR_NO_DATA);
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkDelete(address,(string[],string[],bool))', sender, row));
    require(success, ERR_CONSTRAINTS);
    removeIndexFor(row);
    rowRepository().remove(key);
  }

  function updateRow(address sender, table.Row memory newRow) public statusAvailable {
    requireAuthorized(sender);
    require(newRow.names.length == newRow.values.length, ERR_KEY_VALUE_SIZE);
    string memory key = getColumnValue(newRow, keyColumn);
    table.Row memory oldRow = getRow(key);
    require(oldRow.available, ERR_NO_DATA);
    (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkUpdate(address,(string[],string[],bool),(string[],string[],bool))', sender, oldRow, newRow));
    require(success, ERR_CONSTRAINTS);
    for (uint i = 0 ; i < Indices.length ; ++i) {
      // For each index
      string memory columnName = Indices[i].columnName;
      string memory oldColumn = getColumnValue(oldRow, columnName);
      string memory newColumn = getColumnValue(newRow, columnName);
      if (utils.notEquals(oldColumn, newColumn)) {
        Index index = Index(Indices[i].addrezz);
        index.remove(oldColumn, key);
        index.add(newColumn, key);
      }
    }
    rowRepository().set(key, newRow);
  }

  function getRow(string memory key) public view statusAvailable returns (table.Row memory) {
    return rowRepository().get(key);
  }

  function getRows(string[] memory keys, bool reverse) private view statusAvailable returns (table.Row[] memory) {
    return rowRepository().get(keys, reverse);
  }

  /**
   * _orderType
   * -1 : 내림차순 정렬
   * 0 : 정렬 없음
   * 1 : 오름차순 정렬
   */
  function findBy(string memory _column, string memory _start, int _st, string memory _end, int _et, int _orderType)
  public view statusAvailable
  returns (table.Row[] memory) {
    bool bFound = false;
    for (uint i = 0 ; i < Columns.length ; ++i) {
      bFound = bFound || utils.equals(Columns[i].columnName, _column);
    }
    require(bFound, ERR_INVALID_COLUMN);

    // Check if column have index
    for (uint i = 0 ; i < Indices.length ; ++i) {
      if (utils.equals(Indices[i].columnName, _column)) {
        // If index exists for column
        Index index = Index(Indices[i].addrezz);
        if (-1 == _orderType) {
          return getRows(index.findBy(_start, _st, _end, _et), true);
        } else {
          return getRows(index.findBy(_start, _st, _end, _et), false);
        }
      }
    }

    return rowRepository().findBy(_column, _start, _st, _end, _et, _orderType);
  }

  /* Library */
  function getColumnValue(table.Row memory row, string memory columnName) internal pure returns (string memory) {
    for (uint i = 0 ; i < row.names.length ; ++i) {
      if (utils.equals(row.names[i], columnName)) {
        return row.values[i];
      }
    }
    return "";
  }

  function intToString(int v) public pure returns (string memory) {
    uint maxlength = 100;
    bytes memory reversed = new bytes(maxlength);
    uint i = 0;
    while (v != 0) {
      int remainder = v % 10;
      v = v / 10;
      reversed[i++] = byte(int8(48 + remainder));
    }
    bytes memory s = new bytes(i + 1);
    for (uint j = 0; j <= i; j++) {
      s[j] = reversed[i - j];
    }
    return string(s);
  }
}
