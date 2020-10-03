pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../../common/ValuePoint.sol';
import './NodeRepository.sol';

interface TreeVisitor {
  function findBy(NodeRepository repository, ValuePoint calldata start, ValuePoint calldata end) external view returns (string[] memory);
  function countBy(NodeRepository repository, ValuePoint calldata start, ValuePoint calldata end) external view returns (uint);
}
