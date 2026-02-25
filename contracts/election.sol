// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import { Candidate } from "./ElectionLibrary.sol";

import "./big.sol";
import "./Registration.sol";
import "./Nomination.sol";

contract ElectionFacade {
    enum ElectionPhase { PreElection, VotingPhaseOne, VotingPhaseTwo, PostElection }

    BigVoting private votingContract;
    Registration private registrationContract;
    Nomination private nominationContract;
    address private owner;
    ElectionPhase private currentPhase;

    /// @dev This emits when the owner of the contract declares that the pre-election 
    /// (registration + nomination) phase has ended.
    event EndPreElectionPhase();

    constructor() {
        owner = msg.sender;
        currentPhase = ElectionPhase.PreElection;
    }

    function setContractAddresses(address _votingContract, address _registrationContract, address _nominationContract) external {
        require(msg.sender == owner, "Operation denied. You are not the owner.");
        votingContract = BigVoting(_votingContract);
        registrationContract = Registration(_registrationContract);
        nominationContract = Nomination(_nominationContract);        
    }

    // Registration
    function register() onlyPreElection external {
        registrationContract.register(msg.sender);
    }

    // Nominations
    function nominate(string calldata firstName, string calldata lastName) haveVotingPower onlyPreElection external {
        nominationContract.nominate(msg.sender, firstName, lastName);
    }

    function endorse(address nominee) haveVotingPower onlyPreElection external {
        nominationContract.endorse(msg.sender, nominee);
    }

    // Functions pertaining to phase transition

    function endPreElectionPhase() external onlyPreElection {
        require(owner == msg.sender, "Only owner of contract can end the pre-election phase");

        Candidate[] memory candidates = nominationContract.getCandidateList();
        
        require(candidates.length > 1, "There must be more than 1 candidate to end the pre-election phase.");

        currentPhase = ElectionPhase.VotingPhaseOne;
        votingContract.setPostRegistrationNumberOfParticipants(registrationContract.getParticipantCount());
        votingContract.setPostNominationCandidateInfo(candidates);
        emit EndPreElectionPhase();
    }

    // Voting

    function vote(address candidate) external haveVotingPower onlyVotingPhase {
        require(
            isCandidate(candidate), 
            "Operation denied. EOA referenced by parameter candidate must be a valid candidate in the election."
        );

        bool hasExceededVotingPhaseParticipationThreshold =
            votingContract.vote(msg.sender, candidate, currentPhase == ElectionPhase.VotingPhaseOne);

        if (hasExceededVotingPhaseParticipationThreshold) 
        {
            (, currentPhase) = votingContract.getResult(currentPhase == ElectionPhase.VotingPhaseTwo);
        }
    }

    // Results
    function getResult() external view onlyPostElection returns (Candidate memory) {
        Candidate[10] memory votingContractCandidateInfo = votingContract.getCandidateInfo();
        return votingContractCandidateInfo[0];
    }

    // View functions

    // Participant registration and candidate state can be shown in the frontend using the emitted
    // events rather than calling view function

    function isCandidate(address participantAddress) private view returns (bool) {
        return nominationContract.isCandidate(participantAddress);
    }

    function isParticipantRegistered(address participantAddress) private view returns (bool) {
        return registrationContract.isParticipantRegistered(participantAddress);
    }

    // modifiers

    modifier haveVotingPower() 
    {
        require(isParticipantRegistered(msg.sender) == true, "Operation denied. EOA is not a registered participant.");
        _;
    } 

    modifier onlyInPhase(ElectionPhase _phase) 
    {
        require(
            currentPhase == _phase, 
            "Function cannot be called in this phase"
        );
        _;
    }

    modifier onlyPreElection() {
        require(
            currentPhase == ElectionPhase.PreElection, 
            "Operation denied. Election is not in pre-election phase."
        );
        _;
    }

    modifier onlyVotingPhase() {
        require(
            currentPhase == ElectionPhase.VotingPhaseOne 
                || currentPhase == ElectionPhase.VotingPhaseTwo, 
            "Operation denied. Election is not in a voting phase."
        );
        _;
    }

    modifier onlyPostElection() {
        require(
            currentPhase == ElectionPhase.PostElection, 
            "Operation denied. Election is not in post-election phase."
        );
        _;
    }
}
