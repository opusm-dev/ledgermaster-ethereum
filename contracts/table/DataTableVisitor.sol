pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "./RowRepository.sol";
import './TableColumn.sol';
import './TableMetadata.sol';
import './TableRow.sol';
import './TableVisitor.sol';

import '../common/Comparator.sol';
import '../common/StringUtils.sol';
import '../common/ValuePoint.sol';
import '../common/ValuePointUtils.sol';
import '../common/proxy/Controlled.sol';

import '../index/Index.sol';

contract DataTableVisitor is TableVisitor, Controlled {
  /* Column-related error */
  string private constant ERR_INVALID_COLUMN = 'INVALID_COLUMN';

  constructor(address _controller) Controlled(_controller) public { }

  function findBy(Table table, uint columnIndex, ValuePoint memory _start, ValuePoint memory _end, int _orderType) public view override returns (TableRow[] memory) {
    TableMetadata memory meta = table.getMetadata();
    TableColumn memory column = meta.columns[columnIndex];
    RowRepository rowRepository = RowRepository(meta.rowRepository);
    Comparator comparator = Comparator(getModule(COMPARATOR + column.dataType));

    // Check if it is key and equals
    if (columnIndex == 0 && ValuePointUtils.checkPoint(comparator, _start, _end)) {
      string[] memory keys = new string[](1);
      keys[0] = _start.value;
      return rowRepository.get(keys, false);
    } else {
      // Check if column have index
      for (uint i = 0 ; i < meta.indices.length ; ++i) {
        if (meta.indices[i].columnIndex == columnIndex) {
          // If index exists for column
          Index index = Index(meta.indices[i].addrezz);
          if (-1 == _orderType) {
            return rowRepository.get(index.findBy(_start, _end), true);
          } else {
            return rowRepository.get(index.findBy(_start, _end), false);
          }
        }
      }

      return rowRepository.findBy(column, _start, _end, _orderType);
    }
  }

  function countBy(Table table, uint columnIndex, ValuePoint memory _start, ValuePoint memory _end) public view override returns (uint) {
    TableMetadata memory meta = table.getMetadata();
    TableColumn memory column = meta.columns[columnIndex];
    RowRepository rowRepository = RowRepository(meta.rowRepository);
    Comparator comparator = Comparator(getModule(COMPARATOR + column.dataType));

    // Check if it is key and equals
    if (_start.boundType == -1 && _end.boundType == -1) {
      return rowRepository.size();
    } else if (columnIndex == 0 && ValuePointUtils.checkPoint(comparator, _start, _end)) {
      if (rowRepository.get(_start.value).available) {
        return 1;
      } else {
        return 0;
      }
    } else {
      // Check if column have index
      for (uint i = 0 ; i < meta.indices.length ; ++i) {
        if (meta.indices[i].columnIndex == columnIndex) {
          // If index exists for column
          Index index = Index(meta.indices[i].addrezz);
          return index.countBy(_start, _end);
        }
      }

      return rowRepository.countBy(column, _start, _end);
    }
  }
}