// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.20;

contract GovernanceNFT {
  // This NFT is non-ERC721 compliant as implementing the ERC721 interface would require there to be 
  // approved addresses and operators which are unwanted. Furthermore contract accounts will not
  // own tokens since they will be blocked from registering in the election so the additional assertion
  // that is required in safeTransferFrom in the ERC721 interface is unnecessary

  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);  

  address private electionContractAddress;  

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    _;
  }

  constructor(address electionContractAddressParam) {
    electionContractAddress = electionContractAddressParam;
  }  

  // Mapping from token ID to owner address
  mapping(uint => address) internal _ownerOf;  
  // Mapping owner address to token count
  mapping(address => uint) internal _balanceOf;  

  function balanceOf(address owner) external view returns (uint balance) {
    return _balanceOf[owner];
  }

  function ownerOf(uint tokenId) external view returns (address owner) {
    return _ownerOf[tokenId];
  }
   
  function transferFrom(address from, address to, uint tokenId) onlyElectionContractCanCall public {
    require(msg.sender != _ownerOf[tokenId], "Operation denied. Caller is not authorised to transfer from's tokens.");
    require(from == _ownerOf[tokenId], "Operation denied. From is not the owner of token.");
    require(to != address(0), "transfer to zero address");  
    _balanceOf[from]--;
    _balanceOf[to]++;
    _ownerOf[tokenId] = to;  
    emit Transfer(from, to, tokenId);
  }
}