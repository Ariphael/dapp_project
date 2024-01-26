// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "./voting.sol";
import "./registration.sol";
import "./candidate.sol";
import "./Nomination.sol";

contract ElectionFacade {
    enum ElectionPhase { PreElection, VotingPhaseOne, VotingPhaseTwo, PostElection }

    address public addressToVotingContract;
    address public addressToRegistration;
    address public addressToNomination;
    address private creatorAddress;
    ElectionPhase public currentPhase;

    modifier haveVotingPower() 
    {
        require(isParticipantRegistered(msg.sender) == true, "You are not registered");
        _;
    } 
    
    modifier onlyInPhase(Phase _phase) 
    {
        require(currentPhase == _phase, "Function cannot be called in this phase");
        _;
    }

    modifier onlyPreElection() {
        _;
        onlyInPhase(Phase.pre_election);
    }

    modifier onlyFirstTurn() {
        _;
        onlyInPhase(Phase.first_turn);
    }

    modifier onlySecondTurn() {
        _;
        onlyInPhase(Phase.second_turn);
    }

    modifier onlyPostElection() {
        _;
        onlyInPhase(Phase.post_election);
    }

    ElectionPhase private phase;

    constructor(address _addressToVotingContract, address _addressToRegistration, address _addressToNomination) {
        creatorAddress = msg.sender;
        addressToVoting = _addressToVoting;
        addressToRegistration = _addressToRegistration;
        addressToNomination = addressToNomination;
        phase = ElectionPhase.PreElection;
    }

    // Registration
    function register() onlyPreElection external {
        registration(addressToRegistration).register();
    }

    // Nominations
    function nominate(address newNominee, string calldata firstName, string calldata lastName) haveVotingPower onlyPreElection external {
        registration(addressToNomination).nominate(newNominee, firstName, lastName);
    }

    function endorse(address from, address nominee) haveVotingPower onlyPreElection external {
        registration(addressToNomination).endorse(from, nominee);
    }

    // Functions pertaining to phase transition

    // function endNominationPhase() public {
    //     require(creatorAddress == msg.sender, "Only creator can end nomination phase");
    //     phase = ElectionPhase.VotingPhaseOne;
    // }

    // function endVotingPhaseOne() public {
    //     require(creatorAddress == msg.sender, "Only creator can end voting phase one");
    //     phase = ElectionPhase.VotingPhaseTwo;
    // }

    // function endElection() public {
    //     require(creatorAddress == msg.sender, "Only creator can end election");
    //     phase = ElectionPhase.Results;
    // }

    function StartFirstTurn() internal
    {
        require(creatorAddress == msg.sender, "Only creator can change phase");
        registration(addressToRegistration).endRegistrationPhase();
        currentPhase = Phase.first_turn;
    }

    function StartSecondTurn() internal
    {
        require(creatorAddress == msg.sender, "Only creator can change phase");
        /// TODO add end of first turn logic
        currentPhase = Phase.second_turn;
    }
    function endElection() internal
    {
        require(creatorAddress == msg.sender, "Only creator can change phase");
        voting(addressToVotingContract).endvoting();
    }

    // Voting

    function vote(address candidate) haveVotingPower onlyFirstTurn external 
    {
        if (currentPhase == Phase.first_turn)
        {
            voting(addressToVotingContract).vote(candidate);
        }
        else if (currentPhase == Phase.second_turn)
        {
            voting(addressToVotingContract).voteSecondTurn(candidate);
        }
    }

    // View functions

    // Participant registration and candidate state can be shown in the frontend using the emitted
    // events rather than calling these view functions
    function isParticipantRegistered(address participantAddress) private view returns (bool) {
        return registration(addressToRegistration).isParticipantRegistered(participantAddress);
    }

    function isCandidate(address participantAddress) private view returns (bool) {
        return Nomination(addressToNomination).isCandidate(participantAddress);
    }

    function getCandidate(address candidate) public view returns (int, string memory, string memory, address) 
    {
        return Voting(addressToVotingContract).getCandidate(candidate);
    }

    function getVotes(address candidate) public view returns (int) {
        return Voting(addressToVotingContract).getVotes(candidate);
    }
}
