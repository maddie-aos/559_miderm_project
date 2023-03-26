// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

import "./ownable.sol";
import "./safemath.sol";

contract KittyFactory is Ownable{


    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewKitty(uint kittyId, string name, uint na);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    //uint cooldownTime = 0.5 days;

    struct Kitty {
    string name;
    uint dna;
    uint32 level;
    // uint32 readyTime;
    // uint16 winCount;
    // uint16 lossCount;
  }

  Kitty[] public kitties;

  mapping (uint => address) public kittyToOwner;
  mapping (address => uint) ownerKittyCount;

  function _createKitty(string _name, uint _dna) internal {
    uint id = kitties.push(Kitty(_name, _dna, 1)) - 1;
    kittyToOwner[id] = msg.sender;
    ownerKittyCount[msg.sender] = ownerKittyCount[msg.sender].add(1);
    emit NewKitty(id, _name, _dna);
  }

  function _generateRandomDna(string _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  function createRandomKitty(string _name) public {
    require(ownerKittyCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createKitty(_name, randDna);
  }
function getDna(uint _kittyId) public returns(uint){
  return kitties[_kittyId].dna;
}
function getKittyByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerKittyCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < kitties.length; i++) {
      if (kittyToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}