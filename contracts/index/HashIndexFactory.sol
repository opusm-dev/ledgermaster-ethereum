pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../Modules.sol';
import '../common/proxy/ContractFactory.sol';
import './HashIndex.sol';

contract HashIndexFactory is ContractFactory, Modules {
  function create(address /*controller*/, address /*owner*/) public override returns (address) {
    HashIndex index = new HashIndex();
    address addrezz = address(index);
    return addrezz;
  }
}