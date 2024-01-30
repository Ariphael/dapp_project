// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import { Candidate } from "./ElectionLibrary.sol";
import "./election.sol";

contract BigVoting {
  uint private constant VOTING_PHASE_PARTICIPATION_THRESHOLD_PERCENTAGE = 80;

  Candidate[10] private candidateInfo;
  mapping(address => Candidate) private candidateMap;
  mapping(address => bool[2]) private hasVoted;
  VotingParticipationInfo private votingParticipationInfo;
  address private electionContractAddress;

  /// @dev This emits when a participant casts a vote. Parameter participationPercentage is a
  /// value between 0-100 representing the new percentage of participants that have cast a
  /// vote.
  event Vote(address voter, address candidate, uint participationPercentage);

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress, "Operation denied. Only election smart contract can call this function.");
    _;
  }

  struct VotingParticipationInfo {
    uint numberOfParticipants;
    uint participationCount;
  }

  constructor(address _electionContractAddress) {
    electionContractAddress = _electionContractAddress;
    votingParticipationInfo.participationCount = 0;
  }

  function vote(address voter, address candidate, bool isPhaseOne) external onlyElectionContractCanCall returns (bool exceededThreshold) {
    require(hasVoted[voter][isPhaseOne ? 0 : 1] == false, "Operation denied. Participant has already cast a vote.");
    require(
      isPhaseOne || (candidate == candidateInfo[0].candidateAddress || candidate == candidateInfo[1].candidateAddress), 
      "Operation denied. Phase two vote invalid candidate."
    );

    if (isPhaseOne)
      candidateMap[candidate].votesFirstTurn++;
    else
      candidateMap[candidate].votesSecondTurn++;

    hasVoted[voter][isPhaseOne ? 0 : 1] = true;

    emit Vote(
      voter, 
      candidate, 
      (votingParticipationInfo.participationCount * 100) / votingParticipationInfo.numberOfParticipants
    );

    uint thresholdNumberOfParticipants = 
      (VOTING_PHASE_PARTICIPATION_THRESHOLD_PERCENTAGE * votingParticipationInfo.numberOfParticipants) / 100;

    return votingParticipationInfo.participationCount >= thresholdNumberOfParticipants;
  }

  function getCandidateInfo() external view onlyElectionContractCanCall returns (Candidate[10] memory) {
    return candidateInfo;
  }

  function setPostNominationCandidateInfo(Candidate[] memory _candidates) external onlyElectionContractCanCall 
  {
    for (uint i = 0; i < candidateInfo.length; i++) {
      if (i < _candidates.length)
        candidateInfo[i] = _candidates[i];
      candidateMap[candidateInfo[i].candidateAddress] = candidateInfo[i];
    }
  }

  function setPostRegistrationNumberOfParticipants(uint numberOfParticipants) external onlyElectionContractCanCall {
    votingParticipationInfo.numberOfParticipants = numberOfParticipants;
  }

  // Result
    function getResult(bool isPhaseTwo) external onlyElectionContractCanCall returns (Candidate[] memory, ElectionFacade.ElectionPhase nextPhase) {
    require(candidateInfo.length > 1, "Operation denied. Number of candidates in election must exceed 1.");

    return !isPhaseTwo ? getPhaseOneResult() : getPhaseTwoResult();
  }

  function getPhaseOneResult() private returns (Candidate[] memory, ElectionFacade.ElectionPhase nextPhase) {
    Candidate[] memory results = new Candidate[](2);

    for (uint i = 0; i < candidateInfo.length; i++) {
      if (candidateInfo[i].votesFirstTurn >= results[0].votesFirstTurn) {
        results[1] = results[0];
        results[0] = candidateInfo[i];
      }
    }
    candidateInfo[0] = results[0];
    candidateInfo[1] = results[1];
    candidateMap[candidateInfo[0].candidateAddress] = candidateInfo[0];
    candidateMap[candidateInfo[1].candidateAddress] = candidateInfo[1];

    emit VotingPhaseOneResult(results[0], results[1]);
    return (results, ElectionFacade.ElectionPhase.VotingPhaseTwo);
  }

  function getPhaseTwoResult() private returns (Candidate[] memory, ElectionFacade.ElectionPhase nextPhase) {
    require(candidateInfo.length == 2, "Operation denied. Only two candidates allowed in voting phase two");

    Candidate[] memory results = new Candidate[](2);
    if (candidateInfo[0].votesSecondTurn > candidateInfo[1].votesSecondTurn) {
      results[0] = candidateInfo[0];
    } else if (candidateInfo[0].votesSecondTurn < candidateInfo[1].votesSecondTurn) {
      results[0] = candidateInfo[1];
    } else {
      // random choice mechanism...
      // let's say candidate votingResults[0] is selected
      results[0] = candidateInfo[0];
    }

    // candidateInfo = results;

    emit VotingPhaseTwoResult(results[0]);
    return (results, ElectionFacade.ElectionPhase.PostElection);
  }

  // events

  /// @dev This emits when the results of voting phase one are the two top voted candidates and neither of these
  /// candidates: (a) Exceed the majority threshold, and (b) have the same quantity of votes
  event VotingPhaseOneResult(Candidate top, Candidate underdog);

  /// @dev This emits when one of the two top voted candidates exceeds the majority threshold
  event ElectionTerminatingVotingPhaseOneResult(Candidate winner);

  /// @dev This emits when one of the two candidates in voting phase two has the majority vote or a tie occurs.
  /// Note: When a tie occurs, a random selection mechanism is employed to independently determine the winner.
  event VotingPhaseTwoResult(Candidate winner);
}