// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "./voting.sol";
import "./registration.sol";
import "./candidate.sol";
import "./Nomination.sol";

contract ElectionFacade {
    enum ElectionPhase { Registration, Nomination, VotingPhaseOne, VotingPhaseTwo, Results }

    address public addressToVoting;
    address public addressToRegistration;
    address private addressToNomination;
    address private creatorAddress;

    ElectionPhase private phase;

    constructor(address _addresssToVoting, address _addressToRegistration, address _addressToNomination) {
        creatorAddress = msg.sender;
        addressToVoting = _addressToVoting;
        addressToRegistration = _addressToRegistration;
        addressToNomination = addressToNomination;
        phase = ElectionPhase.Registration;
    }

    function register() external {
        require(phase == ElectionPhase.Registration, "Operation denied. Election is not in the registration phase.");
        registration(AddressToregistration).register();
    }

    function nominate(string calldata firstName, string calldata lastName) external {
        require(phase == ElectionPhase.Nomination, "Operation denied. Election is not in the nomination phase");
        require(isParticipantRegistered(address(msg.sender)), "Operation denied. Caller is not a participant in the election.");

        Nomination(addressToNomination).nominate(msg.sender, firstName, lastName);
    }

    function endorse(address nominee) external {
        require(phase == ElectionPhase.Nomination, "Operation denied. Election is not in the nomination phase");
        require(isParticipantRegistered(address(msg.sender)), "Operation denied. Caller is not a participant in the election.");

        Nomination(addressToNomination).endorse(msg.sender, nominee);
    }

    function vote(address candidate) external {
        require(
            phase == ElectionPhase.VotingPhaseOne || ElectionPhase.VotingPhaseTwo, 
            "Operation denied. Election is not in a voting phase."
        );
        require(isCandidate(candidate), "Operation denied. Not a candidate.");

        Voting(addressToVoting).vote(candidate);
    }

    function voteSecondTurn(address candidate) external {
        require(
            phase == ElectionPhase.VotingPhaseOne || ElectionPhase.VotingPhaseTwo, 
            "Operation denied. Election is not in a voting phase."
        );
        require(isCandidate(candidate), "Operation denied. Not a candidate.");

        Voting(addressToVoting).voteSecondTurn(candidate);
    }

    // function getVotes(address candidate) public view returns (int) {
    //     return Voting(AddresssToVoting).getVotes(candidate);
    // }

    // function getVotesSecondTurn(address candidate) public view returns (int) {
    //     return Voting(AddresssToVoting).getVotesSecondTurn(candidate);
    // }

    // function getCandidate(address candidate) public view returns (int, string memory, string memory, address) {
    //     return Voting(AddresssToVoting).getCandidate(candidate);
    // }

    function endRegistrationPhase() public {
        require(creatorAddress == msg.sender, "Only creator can end registration phase");
        registration(AddressToRegistration).endRegistrationPhase();
        phase = ElectionPhase.Nomination;
    }

    function endNominationPhase() public {
        require(creatorAddress == msg.sender, "Only creator can end nomination phase");
        phase = ElectionPhase.VotingPhaseOne;
    }

    function endVotingPhaseOne() public {
        require(creatorAddress == msg.sender, "Only creator can end voting phase one");
        phase = ElectionPhase.VotingPhaseTwo;
    }

    function endElection() public {
        require(creatorAddress == msg.sender, "Only creator can end election");
        phase = ElectionPhase.Results;
    }

    // Participant registration and candidate state can be shown in the frontend using the emitted
    // events rather than calling these view functions
    function isParticipantRegistered(address participantAddress) private view returns (bool) {
        return registration(AddressToRegistration).isParticipantRegistered(participantAddress);
    }

    function isCandidate(address participantAddress) private view returns (bool) {
        return Nomination(addressToNomination).isCandidate(participantAddress);
    }
}
