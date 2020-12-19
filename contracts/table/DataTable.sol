pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

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
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_DATA_TABLE_INDICES';
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
  mapping(string => uint) private RowIndices;
  mapping(string => string[]) private Rows;

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
    name = _name;
    ColumnInput memory keyColumn = ColumnInput({
      name: _keyColumnName,
      dataType: _keyColumnType
    });
    addColumn(keyColumn);
  }

  function getStore() public override returns (address) {
    return store;
  }

  function getMetadata()
  public view override
  returns (TableMetadata memory) {
    return TableMetadata({
      name: name,
      location: address(this),
      columns: Columns,
      indices: Indices
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
  /****************************/
  /* Index-related governance */
  /****************************/
  function addIndex(IndexInput memory index) public {
    (bool success,) = getModule(PART_INDICES).delegatecall(abi.encodeWithSignature('addIndex(string,uint256)', index.indexName, getColumnIndex(index.columnName)));
    require(success, 'fail to add a index');
  }
  /**
   * Status 확인은 public에서 미리 확인하도록 함
   */
  function addIndexFor(string[] memory row) private {
    // Row key
    string memory key = row[0];
    // iterate indices
    for (uint i = 0 ; i < Indices.length ; ++i) {
      // For each index
      uint columnIndex = Indices[i].columnIndex;
      Index index = Index(Indices[i].addrezz);
      index.add(row[columnIndex], key);
    }
  }
  /**
   * Status 확인은 public에서 미리 확인하도록 함
   */
  function removeIndexFor(string[] memory row) private {
    // Row key
    string memory key = row[0];
    // iterate indices
    for (uint i = 0 ; i < Indices.length ; ++i) {
      // For each index
      uint columnIndex = Indices[i].columnIndex;
      Index index = Index(Indices[i].addrezz);
      index.remove(row[columnIndex], key);
    }
  }
  /**************************/
  /* Row-related governance */
  /**************************/
  function add(string[] memory row) public {
    add(msg.sender, row);
  }

  function remove(string memory key) public {
    remove(msg.sender, key);
  }

  function update(string[] memory newRow) public {
    update(msg.sender, newRow);
  }

  function add(address sender, string[] memory values) public {
    string memory key = values[0];
    require(Columns.length == values.length, ERR_KEY_VALUE_SIZE);
    require(0 < getRow(key).length, ERR_ALREADY_EXIST);
    if (0 < Constraints.length) {
      (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkInsert(address,string[])', sender, values));
      require(success, ERR_INSERT_CONSTRAINT);
    }
    setRow(key, values);
    addIndexFor(values);
  }

  function remove(address sender, string memory key) public {
    requireAuthorized(sender);
    // Check if it exists
    string[] memory values = getRow(key);
    require(0 < values.length, ERR_NO_DATA);
    if (0 < Constraints.length) {
      (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkDelete(address,string[])', sender, values));
      require(success, ERR_DELETE_CONSTRAINT);
    }
    removeIndexFor(values);
    removeRow(key);
  }

  function update(address sender, string[] memory newRow) public {
    if (msg.sender != sender) {
      requireAuthorized(sender);
    }
    require(Columns.length == newRow.length, ERR_KEY_VALUE_SIZE);
    if (0 < Constraints.length) {
      string[] memory oldRow = getRow(newRow[0]);
      (bool success,) = getModule(PART_CONSTRAINTS).delegatecall(abi.encodeWithSignature('checkUpdate(address,string[],string[])', sender, oldRow, newRow));
      require(success, ERR_UPDATE_CONSTRAINT);
    }
    if (0 < Indices.length) {
      string[] memory oldRow = getRow(newRow[0]);
      if (0 < oldRow.length) {
        for (uint i = 0 ; i < Indices.length ; ++i) {
          // For each index
          uint columnIndex = Indices[i].columnIndex;
          string memory oldColumn = oldRow[columnIndex];
          string memory newColumn = newRow[columnIndex];
          if (StringUtils.notEquals(oldColumn, newColumn)) {
            Index index = Index(Indices[i].addrezz);
            index.remove(oldColumn, newRow[0]);
            index.add(newColumn, newRow[0]);
          }
        }
      } else {
        for (uint i = 0 ; i < Indices.length ; ++i) {
          // For each index
          Index index = Index(Indices[i].addrezz);
          uint columnIndex = Indices[i].columnIndex;
          string memory newColumn = newRow[columnIndex];
          index.add(newColumn, newRow[0]);
        }
      }
    }
    setRow(newRow[0], newRow);
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
  external view override
  returns (string[][] memory) {
    TableVisitor visitor = TableVisitor(getModule(TABLE_VISITOR));
    return visitor.findBy(this, getColumnIndex(_column), _start, _end, _orderType);
  }

  function countBy(string calldata _column, ValuePoint calldata _start, ValuePoint calldata _end)
  external view
  returns (uint) {
    TableVisitor visitor = TableVisitor(getModule(TABLE_VISITOR));
    return visitor.countBy(this, getColumnIndex(_column), _start, _end);
  }

  /* Library */
  function getColumnIndex(string memory columnName) internal view returns (uint) {
    for (uint i = 0 ; i < Columns.length ; ++i) {
      if (StringUtils.equals(Columns[i].name, columnName)) {
        return i;
      }
    }
    require(false, ERR_NO_COLUMN);
    return 0;
  }

  function getRow(string memory key) public view override returns (string[] memory) {
    return Rows[key];
  }

  function listRow(string[] memory keys, bool reverse) public view override returns (string[][] memory) {
    string[][] memory rows = new string[][](keys.length);
    if (reverse) {
      for (uint i = 0 ; i < keys.length ; ++i) {
        rows[i] = Rows[keys[keys.length - i - 1]];
        require(0 < rows[i].length, ERR_ILLEGAL);
      }
    } else {
      for (uint i = 0 ; i < keys.length ; ++i) {
        rows[i] = Rows[keys[i]];
        require(0 < rows[i].length, ERR_ILLEGAL);
      }
    }
    return rows;
  }

  function setRow(string memory key, string[] memory row) private {
    string[] memory oldRowNode = Rows[key];
    if (0 == oldRowNode.length) {
      // 존재하지 않으면
      Keys.push(key);
      RowIndices[key] = Keys.length - 1;
    }
    Rows[key] = row;
  }
  function removeRow(string memory key) public {
    string[] memory values = Rows[key];
    if (0 < values.length) {
      uint index = RowIndices[key];
      delete Rows[key];
      delete RowIndices[key];
      if (Keys.length-1 != index) {
        string memory lastKey = Keys[Keys.length-1];
        Keys[index] = lastKey;
        RowIndices[lastKey] = index;
      }
      Keys.pop();
    }
  }

  function size() public view override returns (uint) {
    return Keys.length;
  }

  function findRowsBy(TableColumn memory _column, ValuePoint memory _start, ValuePoint memory _end, int _orderType) public view override returns (string[][] memory) {
    string[][] memory _list = listRow(Keys, false);
    string[][] memory filteredRows = filter(_list, _column, _start, _end);
    if (0 != _orderType) {
      string[][] memory ascendingSorted = sort(filteredRows, _column, 0, filteredRows.length);
      if (-1 == _orderType) {
        return reverse(filteredRows);
      }
      return ascendingSorted;
    } else {
      return filteredRows;
    }
  }
  function countRowsBy(TableColumn memory _column, ValuePoint memory _start, ValuePoint memory _end) public view override returns (uint) {
    string[][] memory _list = listRow(Keys, false);
    uint n = 0;
    Comparator comparator = Comparator(getModule(COMPARATOR + _column.dataType));
    for (uint i = 0 ; i<_list.length ; ++i) {
      string memory value = _list[i][_column.index];
      if (ValuePointUtils.checkBound(comparator, _start, _end, value)) {
        ++n;
      }
    }
    return n;
  }

  function filter(string[][] memory _list, TableColumn memory _column, ValuePoint memory _start, ValuePoint memory _end) private view returns (string[][] memory) {
    uint n = 0;
    bool[] memory accepts = new bool[](_list.length);
    Comparator comparator = Comparator(getModule(COMPARATOR + _column.dataType));
    for (uint i = 0 ; i<_list.length ; ++i) {
      string memory value = _list[i][_column.index];
      if (ValuePointUtils.checkBound(comparator, _start, _end, value)) {
        accepts[i] = true;
        ++n;
      } else {
        accepts[i] = false;
      }
    }
    string[][] memory filtered = new string[][](n);
    uint targetIndex = 0;
    for (uint sourceIndex = 0 ; sourceIndex < _list.length ; ++sourceIndex) {
      if (accepts[sourceIndex]) {
        filtered[targetIndex++] = _list[sourceIndex];
      }
    }
    return filtered;
  }

  /**
 * 3 way quick sort
 */
  function sort(string[][] memory _list, TableColumn memory _column, uint _start, uint _end) private view returns (string[][] memory) {
    if (_end - _start < 2) {
      return _list;
    }
    uint bandStart = _start;
    uint bandEnd = _start;
    uint i = _start + 1;
    string memory bandValue = _list[bandStart][_column.index];

    Comparator comparator = Comparator(getModule(COMPARATOR + _column.dataType));
    string[] memory temp;
    while (i < _end) {
      string memory v = _list[i][_column.index];
      int comparison = comparator.compare(bandValue, v);
      if (0 == comparison) {
        ++bandEnd;
      } else if (comparison > 0) {
        temp = _list[bandStart];
        _list[bandStart] = _list[i];
        _list[i] = _list[bandEnd+1];
        _list[bandEnd+1] = temp;
        ++bandStart;
        ++bandEnd;
      }
      ++i;
    }
    return sort(sort(_list, _column, _start, bandStart), _column, bandEnd + 1, _end);
  }

  function reverse(string[][] memory _list) private pure returns (string[][] memory) {
    uint middlePoint = _list.length / 2;
    string[] memory temp;
    for (uint i = 0 ; i < middlePoint ; ++i) {
      temp = _list[i];
      _list[i] = _list[_list.length - i - 1];
      _list[_list.length - i - 1] = temp;
    }
    return _list;
  }


}
