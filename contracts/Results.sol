// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "./candidate.sol";
import "./election.sol";

contract Results {
  Candidate[] private votingResults;
  address private electionContractAddress;

  /// @dev This emits when the results of voting phase one are the two top voted candidates and neither of these
  /// candidates: (a) Exceed the majority threshold, and (b) have the same quantity of votes
  event VotingPhaseOneResult(Candidate top, Candidate underdog);

  /// @dev This emits when one of the following conditions occur: (a) One of the two top voted candidates exceeds
  /// the majority threshold, or (b) A tie occurs.
  /// Note: In the case of (b), a random selection mechanism is employed to independently determine the winner.
  event ElectionTerminatingVotingPhaseOneResult(Candidate winner);

  /// @dev This emits when one of the two candidates in voting phase two has the majority vote or a tie occurs.
  /// Note: When a tie occurs, a random selection mechanism is employed to independently determine the winner.
  event VotingPhaseTwoResult(Candidate winner);

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    _;
  }

  constructor(address _electionContractAddress) {
    electionContractAddress = _electionContractAddress;
  }

  function setCandidateVotingResults(Candidate[] memory candidateVotingResults) external onlyElectionContractCanCall {
    votingResults = candidateVotingResults;
  }

  function getResult(bool isPhaseTwo) external onlyElectionContractCanCall returns (Candidate[], ElectionPhase nextPhase) {
    require(votingResults.length > 1, "Operation denied. Number of candidates in election must exceed 1.");

    return !isPhaseTwo ? getPhaseOneResult() : getPhaseTwoResult();
  }

  function getPhaseOneResult() private returns (Candidate[], ElectionPhase nextPhase) {
    Candidate[] results = new Candidate[](2);

    for (uint i = 0; i < votingResults.length; i++) {
      if (votingResults[i].votesFirstTurn >= results[0].votesFirstTurn) {
        results[1] = results[0];
        results[0] = votingResults[i];
      }
    }

    if (results[0].votesFirstTurn == results[1].votesFirstTurn) {
      Candidate[] resultTie = new Candidate[](1);
      // random choice mechanism...
      resultTie[0] = results[0];
      emit ElectionTerminatingVotingPhaseOneResult(resultTie[0]);
      return (resultTie, ElectionFacade.ElectionPhase.VotingPhaseOne);
    }

    emit VotingPhaseOneResult(results[0], results[1]);
    return (results, ElectionFacade.ElectionPhase.VotingPhaseTwo);
  }

  function getPhaseTwoResult() private returns (Candidate[]) {
    require(votingResults.length == 2, "Operation denied. Only two candidates allowed in voting phase two");

    Candidate[] results = new Candidate[](1);
    if (votingResults[0].votesSecondTurn > votingResults[1].votesSecondTurn) {
      results[0] = votingResults[0];
    } else if (votingResults[0].votesSecondTurn < votingResults[1].votesSecondTurn) {
      results[0] = votingResults[1];
    } else {
      // random choice mechanism...
      // let's say candidate votingResults[0] is selected
      results[0] = votingResults[0];
    }

    emit VotingPhaseTwoResult(results[0]);
    return results;
  }
}