// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "./Voting.sol";
import "./Registration.sol";
import "./Results.sol";
import "./candidate.sol";
import "./Nomination.sol";

contract ElectionFacade {
    enum ElectionPhase { PreElection, VotingPhaseOne, VotingPhaseTwo, PostElection }

    Voting private votingContract;
    Registration private registrationContract;
    Nomination private nominationContract;
    Results private resultsContract;
    address private owner;
    ElectionPhase private currentPhase;

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

    constructor(
        address _votingContract, 
        address _registrationContract, 
        address _nominationContract, 
        address _resultsContract
    ) {
        owner = msg.sender;
        votingContract = Voting(_votingContract);
        registrationContract = Registration(_registrationContract);
        nominationContract = Nomination(_nominationContract);
        resultsContract = Results(_resultsContract);
        currentPhase = ElectionPhase.PreElection;
    }

    // Registration
    function register() onlyPreElection external {
        registrationContract.register();
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
        currentPhase = ElectionPhase.PreElection;
    }

    // Voting

    function vote(address candidate) external haveVotingPower onlyVotingPhase {
        require(
            isCandidate(candidate), 
            "Operation denied. EOA referenced by parameter candidate must be a valid candidate in the election."
        );

        bool hasExceededVotingPhaseParticipationThreshold =
            votingContract.vote(msg.sender, candidate, currentPhase == ElectionPhase.PhaseOne);

        if (hasExceededVotingPhaseParticipationThreshold) {
            Candidate[] memory candidateInfo = Voting(votingContract).getCandidateInfo();
            resultsContract.setCandidateVotingResults(candidateInfo);
            (,currentPhase) = resultsContract.getResult(currentPhase == ElectionPhase.VotingPhaseTwo);
            if (currentPhase != ElectionPhase.PostElection)
                votingContract.setPostNominationCandidateInfo(
                    registrationContract.getVotingResults()
                );
        }
    }

    // Results
    function getResult() external view onlyPostElection returns (Candidate[] memory) {
        return registrationContract.getVotingResults();
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
}
