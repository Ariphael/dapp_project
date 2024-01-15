pragma solidity ^0.5.2;

contract registration {
  address private electionContractAddress;
  mapping(address => bool) isRegistered;
  bool private registrationPhaseFlag;

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    _;
  }

  constructor() public {
    registrationPhaseFlag = true;
  }

  function register() external {
    require(registrationPhaseFlag == true, "Operation denied. Election is not in registration phase.");
    require(!isRegistered[msg.sender], "Operation denied. You are already registered in this election.");

    // Identity verification...

    isRegistered[msg.sender] = true;
  }

  function endRegistrationPhase() public onlyElectionContractCanCall {
    registrationPhaseFlag = false;
  }
}