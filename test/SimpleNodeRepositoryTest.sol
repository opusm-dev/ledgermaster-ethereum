pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

import "truffle/Assert.sol";
import "../contracts/repository/SimpleNodeRepository.sol";

contract SimpleNodeRepositoryTest {
  function testSetGet() public {
    SimpleNodeRepository repo = new SimpleNodeRepository();
    Assert.isEmpty(repo.get("hello").key, "No result in repository");
    tree.Node memory node = tree.Node({
      kind: bytes1(0x01),
      key: 'hello',
      values: new string[](0),
      left: '',
      right: ''
    });
    repo.set(node);
    Assert.equal("hello", repo.get("hello").key, "No result in repository");
  }
}