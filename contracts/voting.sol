// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;
import "./candidate.sol";

contract Voting  
{
  bool private votingPhaseFlag;
  address private electionContractAddress;
  mapping(address => bool) hasVoted;
  mapping(address => bool) isCandidate;

  mapping(address => Candidate) candidatesMAP;
  address[] public candidateAddresses;
  uint64[2] public topVotes;
  address[2] public topCandidates;
  address public winner;
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

  function voteSecondTurn(address candidate) external
  {
    require(votingPhaseFlag == true, "Operation denied. Election is not in voting phase.");
    require(!hasVoted[msg.sender], "Operation denied. You are already voted in this election.");
    hasVoted[msg.sender] = true;
    require((candidate == topCandidates[0]) || (candidate == topCandidates[1]), "Operation denied. Candidate is not in the second turn.");

    candidatesMAP[candidate].votesSecondTurn = candidatesMAP[candidate].votesSecondTurn + 1;
  }

  function endvoting() external
  {
    require(electionContractAddress == msg.sender, "Only creator can end voting phase");
    votingPhaseFlag = false;
  }

  function getVotes(address candidate) public view returns (uint64) 
  {
    return candidatesMAP[candidate].votesFirstTurn;
  }

  function getVotesSecondTurn(address candidate) public view returns (uint64) 
  {
    return candidatesMAP[candidate].votesSecondTurn;
  }

  function getTwoWinning() external
  {
    require(!votingPhaseFlag, "Voting phase is still ongoing.");

    for (uint i = 0; i < candidateAddresses.length; i++) 
    {
        address candidateAddress = candidateAddresses[i];
        uint64 votes = candidatesMAP[candidateAddress].votesFirstTurn;
        if (votes > topVotes[0]) {
            topVotes[1] = topVotes[0];
            topCandidates[1] = topCandidates[0];
            topVotes[0] = votes;
            topCandidates[0] = candidateAddress;
        } else if (votes > topVotes[1]) {
            topVotes[1] = votes;
            topCandidates[1] = candidateAddress;
        }
    }
    checkNeedOfSecondTurn();
  }

  
  //topCandidate[0] is the candidate adress with most votes
  //topCandidates[1] is the second candidate adress with most vots
  //topVotes[0] is the biggest amount of votes (votes of topCandidates[0])(int)
  //topVotes[1] is the second biggest amount of votes (votes of topCandidates[1])(int)

  function checkNeedOfSecondTurn() internal returns (bool) {
    uint64 totalVotes = getTotalVotes();

    uint64 majorityThreshold = (totalVotes * 50);
    if (topVotes[0]>= majorityThreshold) {
      //first candidate won in the current round
      winner = topCandidates[0];

      return false;
    }
    //SECOND TURN
    else {
      votingPhaseFlag = true;

      //allow voters to vote again
      for (uint i = 0; i < candidateAddresses.length; i++) {
          hasVoted[candidateAddresses[i]] = false;
      }

      return true;
    }
  }

  function determineSecondTurnWinner() external {

      address candidate1 = topCandidates[0];
      address candidate2 = topCandidates[1];
      uint64 votesCandidate1 = getVotesSecondTurn(candidate1);
      uint64 votesCandidate2 = getVotesSecondTurn(candidate2);

      if (votesCandidate1 > votesCandidate2) {
          winner = candidate1;
      } else {
          winner = candidate2;
      } 
      //i put an else and not an elseif because idk what to do for a tie
  }

<<<<<<< HEAD
  function getTotalVotes() returns (int){
    uint256 totalVotes = 0;
    //loop the candidate list to get total
    for (uint i = 0; i < candidateAddresses.length; i++) {
=======


  function getTotalVotes() public view returns (uint64){
    uint64 totalVotes = 0;
    //loop the candidate list to get total
    for (uint64 i = 0; i < candidateAddresses.length; i++) {
>>>>>>> bd8684b931a608bf88423fb4390b7b297158bd34

        address candidate = candidateAddresses[i];

        uint64 votes = getVotes(candidate);

        totalVotes += uint64(votes);
    }

    return totalVotes;

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