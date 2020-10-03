pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../common/proxy/Controller.sol';
import '../common/proxy/ContractFactory.sol';

import './SimpleRowRepository.sol';

contract SimpleRowRepositoryFactory is ContractFactory {
  event NewRowRepository(address addrezz);
  function create(address _controller, address owner) external override returns (address) {
    SimpleRowRepository repository = new SimpleRowRepository(_controller);
    repository.changeOwner(owner);
    address addrezz = address(repository);
    emit NewRowRepository(addrezz);
    return addrezz;
  }
}
