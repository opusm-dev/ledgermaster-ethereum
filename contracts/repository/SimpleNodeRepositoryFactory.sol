pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "../ContractFactory.sol";
import "./SimpleNodeRepository.sol";

contract SimpleNodeRepositoryFactory is ContractFactory {
  mapping(string => address) contracts;

  function create(string memory key) public override {
    require(address(0) == contracts[key]);
    SimpleNodeRepository repository = new SimpleNodeRepository();
    repository.changeOwner(msg.sender);
    contracts[key] = address(repository);
  }

  function get(string memory key) public view override returns (address) {
    return contracts[key];
  }

}