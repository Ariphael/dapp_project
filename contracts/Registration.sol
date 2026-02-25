// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

contract Registration {
  address private electionContractAddress;
  mapping(address => bool) isRegistered;
  uint private participantCount;

  /// @dev This emits when a new participant is registered in the election.
  event Register(address newParticipant);

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress, "Operation denied. Only election smart contract can call this function.");
    _;
  }

  constructor(address electionContractAddressParam) {
    electionContractAddress = electionContractAddressParam;
    participantCount = 0;
  }

  function register(address registree) onlyElectionContractCanCall external {
    require(!isContract(registree), "Operation denied. Only externally owned accounts can register in this election.");
    require(!isRegistered[registree], "Operation denied. You are already registered in this election.");

    // Identity verification...

    isRegistered[registree] = true;
    participantCount++;
    emit Register(registree);
  }

  function isParticipantRegistered(address participantAddress) onlyElectionContractCanCall public view returns (bool) {
    return isRegistered[participantAddress];
  }

  function getParticipantCount() onlyElectionContractCanCall external view returns (uint) {
    return participantCount;
  }

  function isContract(address account) private view returns (bool) {
    uint32 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}