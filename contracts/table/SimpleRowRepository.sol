pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './RowRepository.sol';
import './TableColumn.sol';
import './TableRow.sol';

import '../common/Comparator.sol';
import '../common/StringUtils.sol';
import '../common/ValuePointUtils.sol';
import '../common/proxy/Controlled.sol';


contract SimpleRowRepository is Controlled, RowRepository {
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_ROW_REPOSITORY';
  string private constant ERR_NO_ROW = 'NO_ROW';

  TableRow DUMMY_ROW = TableRow({
    values: new string[](0),
    available: false
  });


  struct RowNode {
    TableRow row;
    uint index;
    bool available;
  }

  string[] Keys;
  mapping(string => RowNode) private Rows;

  constructor(address _controller) Controlled(_controller) public { }

  function size() external view override returns (uint) {
    return Keys.length;
  }

  function get(string memory key) public override view returns (TableRow memory) {
    RowNode memory node = Rows[key];
    if (node.available) {
      return node.row;
    } else {
      return DUMMY_ROW;
    }
  }

  function get(string[] memory keys, bool reverse) public override view returns (TableRow[] memory) {
    TableRow[] memory rows = new TableRow[](keys.length);
    if (reverse) {
      for (uint i = 0 ; i < keys.length ; ++i) {
        rows[i] = Rows[keys[keys.length - i - 1]].row;
        require(rows[i].available, ERR_ILLEGAL);
      }
    } else {
      for (uint i = 0 ; i < keys.length ; ++i) {
        rows[i] = Rows[keys[i]].row;
        require(rows[i].available, ERR_ILLEGAL);
      }
    }
    return rows;
  }

  function set(string memory key, TableRow memory row) public override {
    RowNode memory oldRowNode = Rows[key];
    uint index = oldRowNode.index;
    if (!oldRowNode.row.available) {
      // 존재하지 않으면
      Keys.push(key);
      index = Keys.length - 1;
    }
    row.available = true;
    Rows[key] = RowNode({
      row: row,
      index: index,
      available: true
    });
  }
  function remove(string memory key) public override {
    RowNode memory node = Rows[key];
    if (node.row.available) {
      delete Rows[key];
      if (Keys.length-1 != node.index) {
        string memory lastKey = Keys[Keys.length-1];
        Keys[node.index] = lastKey;
        Rows[lastKey].index = node.index;
      }
      Keys.pop();
    }
  }

  function getAllRows() private view returns (TableRow[] memory) {
    return get(Keys, false);
  }

  function findBy(TableColumn memory _column, ValuePoint memory _start,ValuePoint memory _end, int _orderType)
  public view override
  returns (TableRow[] memory) {
    TableRow[] memory filteredRows = filter(getAllRows(), _column, _start, _end);
    if (0 != _orderType) {
      TableRow[] memory ascendingSorted = sort(filteredRows, _column, 0, filteredRows.length);
      if (-1 == _orderType) {
        return reverse(filteredRows);
      }
      return ascendingSorted;
    } else {
      return filteredRows;
    }
  }

  function countBy(TableColumn memory _column, ValuePoint memory _start, ValuePoint memory _end)
  public view override
  returns (uint) {
    TableRow[] memory _list = getAllRows();
    uint n = 0;
    Comparator comparator = Comparator(getModule(COMPARATOR + _column.dataType));
    for (uint i = 0 ; i<_list.length ; ++i) {
      string memory value = _list[i].values[_column.index];
      if (ValuePointUtils.checkBound(comparator, _start, _end, value)) {
        ++n;
      }
    }
    return n;
  }

  function filter(TableRow[] memory _list, TableColumn memory _column, ValuePoint memory _start, ValuePoint memory _end) private view returns (TableRow[] memory) {
    uint n = 0;
    bool[] memory accepts = new bool[](_list.length);
    Comparator comparator = Comparator(getModule(COMPARATOR + _column.dataType));
    for (uint i = 0 ; i<_list.length ; ++i) {
      string memory value = _list[i].values[_column.index];
      if (ValuePointUtils.checkBound(comparator, _start, _end, value)) {
        accepts[i] = true;
        ++n;
      } else {
        accepts[i] = false;
      }
    }
    TableRow[] memory filtered = new TableRow[](n);
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
  function sort(TableRow[] memory _list, TableColumn memory _column, uint _start, uint _end) private view returns (TableRow[] memory) {
    if (_end - _start < 2) {
      return _list;
    }
    uint bandStart = _start;
    uint bandEnd = _start;
    uint i = _start + 1;
    string memory bandValue = _list[bandStart].values[_column.index];

    Comparator comparator = Comparator(getModule(COMPARATOR + _column.dataType));
    while (i < _end) {
      string memory v = _list[i].values[_column.index];
      int comparison = comparator.compare(bandValue, v);
      if (0 == comparison) {
        ++bandEnd;
      } else if (comparison > 0) {
        TableRow memory temp = _list[bandStart];
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

  function reverse(TableRow[] memory _list) private pure returns (TableRow[] memory) {
    uint middlePoint = _list.length / 2;
    TableRow memory temp;
    for (uint i = 0 ; i < middlePoint ; ++i) {
      temp = _list[i];
      _list[i] = _list[_list.length - i - 1];
      _list[_list.length - i - 1] = temp;
    }
    return _list;
  }

}