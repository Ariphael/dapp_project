// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import { Candidate } from "./ElectionLibrary.sol";
import "./election.sol";

contract Results {
  Candidate[] private postVotingPhaseResults;
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

  function setPostVotingPhaseResults(Candidate[] memory candidateVotingResults) external onlyElectionContractCanCall {
    postVotingPhaseResults = candidateVotingResults;
  }

  function getResult(bool isPhaseTwo) external onlyElectionContractCanCall returns (Candidate[] memory, ElectionFacade.ElectionPhase nextPhase) {
    require(postVotingPhaseResults.length > 1, "Operation denied. Number of candidates in election must exceed 1.");

    return !isPhaseTwo ? getPhaseOneResult() : getPhaseTwoResult();
  }

  function getVotingResults() external returns (Candidate[] memory) {
    return postVotingPhaseResults;
  }

  function getPhaseOneResult() private returns (Candidate[] memory, ElectionFacade.ElectionPhase nextPhase) {
    Candidate[] memory results = new Candidate[](2);

    for (uint i = 0; i < postVotingPhaseResults.length; i++) {
      if (postVotingPhaseResults[i].votesFirstTurn >= results[0].votesFirstTurn) {
        results[1] = results[0];
        results[0] = postVotingPhaseResults[i];
      }
    }

    if (results[0].votesFirstTurn == results[1].votesFirstTurn) {
      Candidate[] memory resultTie = new Candidate[](1);
      // random choice mechanism...
      resultTie[0] = results[0];
      emit ElectionTerminatingVotingPhaseOneResult(resultTie[0]);
      return (resultTie, ElectionFacade.ElectionPhase.PostElection);
    }

    postVotingPhaseResults = results;

    emit VotingPhaseOneResult(results[0], results[1]);
    return (results, ElectionFacade.ElectionPhase.VotingPhaseTwo);
  }

  function getPhaseTwoResult() private returns (Candidate[] memory, ElectionFacade.ElectionPhase nextPhase) {
    require(postVotingPhaseResults.length == 2, "Operation denied. Only two candidates allowed in voting phase two");

    Candidate[] memory results = new Candidate[](1);
    if (postVotingPhaseResults[0].votesSecondTurn > postVotingPhaseResults[1].votesSecondTurn) {
      results[0] = postVotingPhaseResults[0];
    } else if (postVotingPhaseResults[0].votesSecondTurn < postVotingPhaseResults[1].votesSecondTurn) {
      results[0] = postVotingPhaseResults[1];
    } else {
      // random choice mechanism...
      // let's say candidate votingResults[0] is selected
      results[0] = postVotingPhaseResults[0];
    }

    postVotingPhaseResults = results;

    emit VotingPhaseTwoResult(results[0]);
    return (results, ElectionFacade.ElectionPhase.PostElection);
  }
}