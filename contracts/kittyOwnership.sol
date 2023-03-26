pragma solidity ^0.4.25;

import "./kittyFactory.sol";
import "./erc721.sol";
import "./safemath.sol";

contract KittyOwnership is KittyFactory, ERC721 {

  using SafeMath for uint256;
  modifier onlyOwnerOf(uint _kittyId) {
    require(msg.sender == kittyToOwner[_kittyId]);
    _;
  }

  mapping (uint => address) kittyApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerKittyCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return kittyToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerKittyCount[_to] = ownerKittyCount[_to].add(1);
    ownerKittyCount[msg.sender] = ownerKittyCount[msg.sender].sub(1);
    kittyToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (kittyToOwner[_tokenId] == msg.sender || kittyApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      kittyApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }

}