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
  mapping(address => Candidate) candidatesMAP;
  address[] public candidateAddresses;
  int[2] public topVotes;
  address[2] public topCandidates;
  //mapping(address => int) numberofVotes;
  //Candidate[] public candidates;
  
constructor(Candidate[] memory _candidates) 
{
    electionContractAddress = msg.sender;
    votingPhaseFlag = true;

    for (uint i = 0; i < _candidates.length; i++) {
        if (!isCandidate[_candidates[i].candidateAddress]) {
            candidatesMAP[_candidates[i].candidateAddress] = Candidate({
                id: int(i),
                firstName: _candidates[i].firstName,
                lastName: _candidates[i].lastName,
                candidateAddress: _candidates[i].candidateAddress,
                votesFirstTurn: 0,
                votesSecondTurn: 0
            });
            isCandidate[_candidates[i].candidateAddress] = true;
        }
      candidateAddresses.push(_candidates[0].candidateAddress);
    }
}

  function vote(address candidate) external
  {
    require(votingPhaseFlag == true, "Operation denied. Election is not in voting phase.");
    require(!hasVoted[msg.sender], "Operation denied. You are already voted in this election.");
    hasVoted[msg.sender] = true;
    require(isCandidate[candidate], "Operation denied. Candidate is not in the list.");

    // Implement anti-race condition

    candidatesMAP[candidate].votesFirstTurn = candidatesMAP[candidate].votesFirstTurn + 1;
  }

  function endvoting() external
  {
    require(electionContractAddress == msg.sender, "Only creator can end voting phase");
    votingPhaseFlag = false;
  }

  function getVotes(address candidate) public view returns (int) 
  {
    return candidatesMAP[candidate].votesFirstTurn;
  }
  function getTwoWinning() external view returns (address[2] memory) 
  {
    require(!votingPhaseFlag, "Voting phase is still ongoing.");
    address[2] memory winners;
    int[2] memory maxVotes;
    for (uint i = 0; i < candidateAddresses.length; i++) {
        address candidateAddress = candidateAddresses[i];
        int votes = candidatesMAP[candidateAddress].votesFirstTurn;
        if (votes > maxVotes[0]) {
            maxVotes[1] = maxVotes[0];
            winners[1] = winners[0];
            maxVotes[0] = votes;
            winners[0] = candidateAddress;
        } else if (votes > maxVotes[1]) {
            maxVotes[1] = votes;
            winners[1] = candidateAddress;
        }
    }
    return winners;
  }

  function getCandidate(address candidate) public view returns (int, string memory, string memory, address) 
  {
    for (uint i = 0; i < candidateAddresses.length; i++) {
      if (candidatesMAP[candidateAddresses[i]].candidateAddress == candidate) {
        return (
          candidatesMAP[candidateAddresses[i]].id,
          candidatesMAP[candidateAddresses[i]].firstName,
          candidatesMAP[candidateAddresses[i]].lastName,
          candidatesMAP[candidateAddresses[i]].candidateAddress
        );
      }
    }
    revert("Candidate not found");
  }
}


