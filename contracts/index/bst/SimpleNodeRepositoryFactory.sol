pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import '../../common/proxy/Controller.sol';
import '../../common/proxy/ContractFactory.sol';

import './SimpleNodeRepository.sol';

contract SimpleNodeRepositoryFactory is ContractFactory {
  event NewNodeRepository(address addrezz);
  function create(address _controller, address owner) external override returns (address) {
    SimpleNodeRepository repository = new SimpleNodeRepository(_controller);
    repository.changeOwner(owner);
    address addrezz = address(repository);
    emit NewNodeRepository(addrezz);
    return addrezz;
  }
}
