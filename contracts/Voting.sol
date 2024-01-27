// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import { Candidate } from "./ElectionLibrary.sol";
import "./election.sol";

contract Voting {
  uint private constant VOTING_PHASE_PARTICIPATION_THRESHOLD_PERCENTAGE = 80;

  Candidate[] private candidateInfo;
  mapping(address => Candidate) private candidateMap;
  mapping(address => bool) private hasVoted;
  VotingParticipationInfo private votingParticipationInfo;
  address private electionContractAddress;

  /// @dev This emits when a participant casts a vote. Parameter participationPercentage is a
  /// value between 0-100 representing the new percentage of participants that have cast a
  /// vote.
  event Vote(address voter, address candidate, uint participationPercentage);

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
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
    require(hasVoted[voter] == false, "Operation denied. Participant has already cast a vote.");

    if (isPhaseOne)
      candidateMap[candidate].votesFirstTurn++;
    else
      candidateMap[candidate].votesSecondTurn++;

    hasVoted[voter] = true;

    emit Vote(
      voter, 
      candidate, 
      (votingParticipationInfo.participationCount * 100) / votingParticipationInfo.numberOfParticipants
    );

    uint thresholdNumberOfParticipants = 
      (VOTING_PHASE_PARTICIPATION_THRESHOLD_PERCENTAGE * votingParticipationInfo.numberOfParticipants) / 100;

    return votingParticipationInfo.participationCount >= thresholdNumberOfParticipants;
  }

  function getCandidateInfo() external onlyElectionContractCanCall returns (Candidate[] memory) {
    return candidateInfo;
  }

  function setPostNominationCandidateInfo(Candidate[] memory _candidateInfo) external onlyElectionContractCanCall {
    candidateInfo = _candidateInfo;

    for (uint i = 0; i < candidateInfo.length; i++) {
      candidateMap[candidateInfo[i].candidateAddress] = candidateInfo[i];
    }
  }

  function setPostRegistrationNumberOfParticipants(uint numberOfParticipants) external onlyElectionContractCanCall {
    votingParticipationInfo.numberOfParticipants = numberOfParticipants;
  }
}