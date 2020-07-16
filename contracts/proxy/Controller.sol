pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import './Controlled.sol';
import '../NodeRepository.sol';
import '../PathFinder.sol';
import '../Index.sol';
import '../ContractFactory.sol';

contract Controller is Controlled {
  string internal constant PREFIX_NO_MODULE = 'CTR_NO_MODULE: ';
  string internal constant PREFIX_DUPLICATED_MODULE = 'CTR_DUPLICATED_MODULE: ';
  string internal constant ERR_MODULE_CREATION_FAILURE = 'CTR_MODULE_CREATION_FAILURE';
  string internal constant ERR_NOT_CONTROLLED = 'CTR_NOT_CONTROLLED';

  mapping (uint => address) internal modules;

  function createModule(uint _id, string memory key) public returns (address) {
    address addrezz = modules[_id];
    require(address(0x0) != addrezz, concat(PREFIX_DUPLICATED_MODULE, uint2string(_id)));
    ContractFactory factory = ContractFactory(addrezz);
    factory.create(key);
    address newModule = factory.get(key);
    require(address(0x0) != newModule, ERR_MODULE_CREATION_FAILURE);
    Controlled(newModule).changeOwner(msg.sender);
    return newModule;
  }

  function getModule(uint _id) public view returns (address) {
    address addrezz = modules[_id];
    require(address(0x0) != addrezz, concat(PREFIX_NO_MODULE, uint2string(_id)));
    return addrezz;
  }

  function setModule(uint _id, address _address) public onlyModulesGovernor {
    modules[_id] = _address;
  }

  function uint2string(uint _i) internal pure returns (string memory) {
    if (_i == 0) {
      return '0';
    }
    uint j = _i;
    uint len = 0;
    while (j != 0) {
      ++len;
      j /= 10;
    }
    bytes memory byteValues = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      byteValues[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(byteValues);
  }

  function concat(string memory _str1, string memory _str2) internal pure returns (string memory) {
    bytes memory bstr1 = bytes(_str1);
    bytes memory bstr2 = bytes(_str2);
    string memory str = new string(bstr1.length + bstr2.length);
    bytes memory b = bytes(str);
    uint k = 0;
    for (uint i = 0; i < bstr1.length; i++) {
      b[k++] = bstr1[i];
    }
    for (uint i = 0; i < bstr2.length; i++) {
      b[k++] = bstr2[i];
    }
    return string(b);
  }
}
