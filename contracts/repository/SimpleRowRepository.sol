pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../lib/tab.sol';
import '../RowRepository.sol';

contract SimpleRowRepository is RowRepository {
  string private constant ERR_ILLEGAL = 'ILLEGAL_STATE_IN_ROW_REPOSITORY';

  struct RowNode {
    table.Row row;
    uint index;
  }

  string[] Keys;
  mapping(string => RowNode) private Rows;

  function get(string memory key) public override view returns (table.Row memory) {
    return Rows[key].row;
  }

  function get(string[] memory keys, bool reverse) public override view returns (table.Row[] memory) {
    table.Row[] memory rows = new table.Row[](keys.length);
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

  function set(string memory key, table.Row memory row) public override {
    RowNode memory oldRowNode = Rows[key];
    uint index = oldRowNode.index;
    if (!oldRowNode.row.available) {
      // 존재하지 않으면
      Keys.push(key);
      index = Keys.length - 1;
    }
    Rows[key] = RowNode({
      row: table.Row({
        names: row.names,
        values: row.values,
        available: true
      }),
      index: index
    });
  }
  function remove(string memory key) public override {
    RowNode memory node = Rows[key];
    if (node.row.available) {
      delete Rows[key];
      Keys[node.index] = Keys[Keys.length-1];
      Keys.pop();
    }
  }

  function getAllRows() private view returns (table.Row[] memory) {
    return get(Keys, false);
  }

  function findBy(string memory _column, string memory _start, int _st, string memory _end, int _et, int _orderType)
  public view override
  returns (table.Row[] memory) {
    table.Row[] memory filteredRows = filter(getAllRows(), _column, _start, _st, _end, _et);
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

  function filter(table.Row[] memory _list, string memory _column, string memory _start, int _st, string memory _end, int _et)
  private pure
  returns (table.Row[] memory) {
    uint n = 0;
    bool[] memory accepts = new bool[](_list.length);
    for (uint i = 0 ; i<_list.length ; ++i) {
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
    for (uint sourceIndex = 0 ; sourceIndex < _list.length ; ++sourceIndex) {
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
    for (uint i = 0 ; i < middlePoint ; ++i) {
      temp = _list[i];
      _list[i] = _list[_list.length - i - 1];
      _list[_list.length - i - 1] = temp;
    }
    return _list;
  }

  /* Library */
  function getColumnValue(table.Row memory row, string memory columnName) internal pure returns (string memory) {
    for (uint i = 0 ; i < row.names.length ; ++i) {
      if (utils.equals(row.names[i], columnName)) {
        return row.values[i];
      }
    }
    return '';
  }

}