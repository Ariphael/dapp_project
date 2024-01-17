pragma solidity ^0.8.20;

contract registration {
  address private electionContractAddress;
  mapping(address => bool) isRegistered;
  bool private registrationPhaseFlag;

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    _;
  }

  constructor(address electionContractAddressParam) {
    electionContractAddress = electionContractAddressParam;
    registrationPhaseFlag = true;
  }

  function register() onlyElectionContractCanCall external {
    require(registrationPhaseFlag == true, "Operation denied. Election is not in registration phase.");
    require(!isRegistered[msg.sender], "Operation denied. You are already registered in this election.");

    // Identity verification...

    isRegistered[msg.sender] = true;
  }

  function isParticipantRegistered(address participantAddress) onlyElectionContractCanCall public view returns (bool) {
    return isRegistered[participantAddress];
  }

  function endRegistrationPhase() onlyElectionContractCanCall public  {
    registrationPhaseFlag = false;
  }
}