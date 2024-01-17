pragma solidity ^0.5.2;

contract secondSC  {
  address private electionContractAddress;
  mapping(address => bool) hasVoted;
  mapping(address => int) numberofVotes;
  bool private votingPhaseFlag;


  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    _;
  }

  constructor(address[] memory candidates) public {
    electionContractAddress = msg.sender;
    votingPhaseFlag = true;

    for (uint i = 0; i < candidates.length; i++) {
      isCandidate[candidates[i]] = true;
    }
  }

  function vote(address candidate) external
  {
    require(VotingPhaseFlag == true, "Operation denied. Election is not in voting phase.");
    require(!hasVoted[msg.sender], "Operation denied. You are already Voted in this election.");
    hasVoted[msg.sender] = true;
    // Implement anti race condition
    numberOfVotes[candidate] += 1;

  }
  function getVotes(address candidate) public view returns (int) {
    return numberOfVotes[candidate];
  }
  function endRegistrationPhase() public onlyElectionContractCanCall {
    votingPhaseFlag = false;
  }
}