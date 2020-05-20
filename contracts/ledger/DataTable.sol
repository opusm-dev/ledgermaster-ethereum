pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "../lib/system.sol";
import "../lib/tab.sol";
import "../proxy/Controller.sol";
import "../proxy/Modules.sol";

import "../Index.sol";
import "../Table.sol";

contract DataTable is Table, Controller, Modules {
  /* Column-related error */
  string private constant ERR_COLUMN_NAME_DUPLICATED = "CTR_COLUMN_NAME_DUPLICATED";
  string private constant ERR_NO_COLUMN = "CTR_NO_COLUMN";

  /* Index-related error */
  string private constant ERR_INDEX_NAME_DUPLICATED = "CTR_INDEX_NAME_DUPLICATED";
  string private constant ERR_INDEXED_COLUMN = "CTR_INDEXED_COLUMN";
  string private constant ERR_NO_INDEX = "CTR_NO_INDEX";

  int constant ST_CREATED = -1;
  int constant ST_AVAILABLE = 0;
  int constant ST_INITIALIZING = 1;
  int constant ST_TEMPORARY_UNAVAILABLE = 2;
  int internal status = ST_CREATED;
  string name;
  string keyColumn;
  table.Column[] Columns;
  table.Index[] Indices;
  mapping(string => table.Row) private rows;

  function initialize(string memory _name, string memory _keyColumn, int _keyColumnType)
  public override {
    require(status == ST_CREATED);
    status = ST_INITIALIZING;
    name = _name;
    keyColumn = _keyColumn;
    addColumn(_keyColumn, _keyColumnType);
    addIndex(name, keyColumn);
    status = ST_AVAILABLE;
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

  /*****************************/
  /* Column-related governance */
  /*****************************/
  function addColumn(string memory _name, int _type) public {
    require(status == ST_AVAILABLE || status == ST_INITIALIZING);
    require(table.validateColumn(_name, _type));
    for (uint i = 0 ; i<Columns.length ; ++i) {
      // Check column name duplication
      require(utils.notEquals(Columns[i].columnName, _name), ERR_COLUMN_NAME_DUPLICATED);
    }
    table.Column memory column = table.Column({
      columnName: _name,
      columnType: _type
    });
    Columns.push(column);
  }

  function removeColumn(string memory _name) public {
    require(status == ST_AVAILABLE);
    uint deletionCount = 0;
    uint beforeColumns = Columns.length;
    // 키 칼럼은 삭제할 수 없다.
    require(utils.notEquals(keyColumn, _name));
    // 인덱스가 있으면 삭제할 수 없다.
    for (uint i = 0 ; i< Indices.length ; ++i ) {
      require(utils.notEquals(Indices[i].columnName, _name), ERR_INDEXED_COLUMN);
    }
    for (uint i=0 ; i<Columns.length ; ++i) {
      uint index = uint(i - deletionCount);
      if (utils.equals(Columns[index].columnName, _name)) {
        Columns[index] = Columns[Columns.length - 1];
        Columns.pop();
        ++deletionCount;
        --i;
      }
    }
    // Check if column deleted
    require(1 == deletionCount, ERR_NO_COLUMN);
    // Check if column size decreased
    require(beforeColumns - deletionCount == Columns.length);
  }

  event XXX();

  /****************************/
  /* Index-related governance */
  /****************************/
  function addIndex(string memory _name, string memory _column) public {
    require(status == ST_AVAILABLE || status == ST_INITIALIZING);
    // Add index
    for (uint i = 0 ; i< Indices.length ; ++i) {
      // Check index name duplication
      require(utils.notEquals(Indices[i].indexName, _name), ERR_INDEX_NAME_DUPLICATED);
      // Check column duplication
      require(utils.notEquals(Indices[i].columnName, _column), ERR_INDEXED_COLUMN);
    }

    address indexAddress = createModule(INDEX_FACTORY, _name);
    Indices.push(table.Index({ indexName: _name, columnName: _column, addrezz: indexAddress }));
  }

  function removeIndex(string memory _name) public {
    require(status == ST_AVAILABLE);
    // Drop index
    uint deletionCount = 0;
    uint beforeIndices = Indices.length;
    require(utils.notEquals(_name, name));
    for (uint i = 0 ; i< Indices.length ; ++i ) {
      uint index = uint(i - deletionCount);
      if (utils.equals(Indices[index].indexName, _name)) {
        Indices[index] = Indices[Indices.length - 1];
        Indices.pop();
        ++deletionCount;
        --i;
      }
    }
    // Check if index deleted
    require(1 == deletionCount, ERR_NO_INDEX);
    // Check if index size decreased
    require(beforeIndices - deletionCount == Indices.length);
  }

  function addIndexFor(table.Row memory row) private {
    require(status == ST_AVAILABLE);
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

  function removeIndexFor(table.Row memory row) private {
    require(status == ST_AVAILABLE);
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
  function addRow(table.Row memory row) public {
    require(status == ST_AVAILABLE);
    string memory key = getColumnValue(row, keyColumn);
    require(row.names.length == row.values.length);
    rows[key] = table.Row({
      names: row.names,
      values: row.values,
      available: true
    });
    addIndexFor(row);
  }

  function removeRow(string memory key) public {
    require(status == ST_AVAILABLE);
    // Check if it exists
    table.Row memory row = rows[key];
    require(row.available);
    removeIndexFor(row);
    delete rows[key];
  }

  function updateRow(table.Row memory newRow) public {
    require(status == ST_AVAILABLE);
    require(newRow.names.length == newRow.values.length);
    string memory key = getColumnValue(newRow, keyColumn);
    table.Row memory oldRow = rows[key];
    require(oldRow.available);
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
    rows[key] = table.Row({
      names: newRow.names,
      values: newRow.values,
      available: true
    });
  }

  function getRow(string memory key) public view returns (table.Row memory) {
    require(status == ST_AVAILABLE);
    return rows[key];
  }

  function getRows(string[] memory keys, bool reverse) private view returns (table.Row[] memory) {
    require(status == ST_AVAILABLE);
    table.Row[] memory r = new table.Row[](keys.length);
    if (reverse) {
      for (uint i=0 ; i<keys.length ; ++i) {
        r[i] = getRow(keys[keys.length - i - 1]);
      }
    } else {
      for (uint i=0 ; i<keys.length ; ++i) {
        r[i] = getRow(keys[i]);
      }
    }
    return r;
  }

  /**
   * _orderType
   * -1 : 내림차순 정렬
   * 0 : 정렬 없음
   * 1 : 오름차순 정렬
   */
  function findBy(string memory _column, string memory _start, int _st, string memory _end, int _et, int _orderType) public view returns (table.Row[] memory) {
    require(status == ST_AVAILABLE, "Status must be ST_AVAILABLE");
    // Check if column have index
    for (uint i=0 ; i< Indices.length ; ++i) {
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

    // If no index for column
    for (uint i=0 ; i< Indices.length ; ++i) {
      if (utils.equals(Indices[i].columnName, keyColumn)) {
        Index index = Index(Indices[i].addrezz);
        table.Row[] memory allRows = getRows(index.findBy('', -1, '', -1), false);
        table.Row[] memory filteredRows = filter(allRows, _column, _start, _st, _end, _et);
        if (0 != _orderType) {
          table.Row[] memory ascendingSorted = sort(filteredRows, _column, 0, filteredRows.length);
          if (-1 == _orderType) {
            return reverse(filteredRows);
          }
          return ascendingSorted;
        } else {
          return filteredRows;
        }
      }
    }
    return getRows(new string[](0), false);
  }

  function filter(table.Row[] memory _list, string memory _column, string memory _start, int _st, string memory _end, int _et) private pure returns (table.Row[] memory) {
    uint n = 0;
    bool[] memory accepts = new bool[](_list.length);
    for (uint i=0 ; i<_list.length ; ++i) {
      string memory value = getColumnValue(_list[i], _column);
      if (utils.checkBound(_start, _st, _end, _et, value)) {
        accepts[i] = true;
        ++n;
      } else {
        accepts[i] = false;
      }
    }
    table.Row[] memory filtered = new table.Row[](n);
    uint targetIndex = 0;
    for (uint sourceIndex=0 ; sourceIndex<_list.length ; ++sourceIndex) {
      if (accepts[sourceIndex]) {
        filtered[targetIndex++] = _list[sourceIndex];
      }
    }
    return filtered;
  }

  function sort(table.Row[] memory _list, string memory _column, uint _start, uint _end) private view returns (table.Row[] memory) {
    if (_end - _start < 2) {
      return _list;
    }
    uint bandStart = _start;
    uint bandEnd = _start;
    uint i = _start + 1;
    string memory bandValue = getColumnValue(_list[bandStart], _column);

    while (i < _end) {
      string memory v = getColumnValue(_list[i], _column);
      int comparison = utils.compare(bandValue, v);
      if (0 == comparison) {
        ++bandEnd;
      } else if (comparison > 0) {
        table.Row memory temp = _list[bandStart];
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

  function reverse(table.Row[] memory _list) private pure returns (table.Row[] memory) {
    uint middlePoint = _list.length / 2;
    table.Row memory temp;
    for (uint i=0 ; i<middlePoint ; ++i) {
      temp = _list[i];
      _list[i] = _list[_list.length - i - 1];
      _list[_list.length - i - 1] = temp;
    }
    return _list;
  }

  /* Library */
  function getColumnValue(table.Row memory row, string memory columnName) internal pure returns (string memory) {
    for (uint i=0 ; i<row.names.length ; ++i) {
      if (utils.equals(row.names[i], columnName)) {
        return row.values[i];
      }
    }
    return "";
  }
}
