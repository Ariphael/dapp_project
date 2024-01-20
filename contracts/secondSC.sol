// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;
import "./candidate.sol";


contract secondSC  
{
  bool private votingPhaseFlag;
  address private electionContractAddress;
  mapping(address => bool) hasVoted;
  mapping(address => bool) isCandidate; 
  mapping(address => int) numberofVotes;
  Candidate[] public candidates;
  
  constructor(Candidate[] memory _candidates)
  {
    electionContractAddress = msg.sender;
    votingPhaseFlag = true;

    for (uint i = 0; i < _candidates.length; i++) 
    {
        candidates.push(Candidate({
            id: int(i),
            firstName: _candidates[i].firstName,
            lastName: _candidates[i].lastName,
            candidateAddress: _candidates[i].candidateAddress
        }));
        isCandidate[_candidates[i].candidateAddress] = true;
    }
  }

  function vote(address candidate) external
  {
    require(votingPhaseFlag == true, "Operation denied. Election is not in voting phase.");
    require(!hasVoted[msg.sender], "Operation denied. You are already voted in this election.");
    hasVoted[msg.sender] = true;
    require(isCandidate[candidate], "Operation denied. Candidate is not in the list.");
    // Implement anti-race condition
    numberofVotes[candidate] += 1;
  }
  
  function getVotes(address candidate) public view returns (int) 
  {
    return numberofVotes[candidate];
  }

  function getCandidate(address candidate) public view returns (int, string memory, string memory, address) 
  {
    for (uint i = 0; i < candidates.length; i++) {
        if (candidates[i].candidateAddress == candidate) {
            return (candidates[i].id, candidates[i].firstName, candidates[i].lastName, candidates[i].candidateAddress);
        }
    }
    revert("Candidate not found");
  }
}


  // function endVotingPhase() public onlyElectionContractCanCall {
  //   votingPhaseFlag = false;
  // }