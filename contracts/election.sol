// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "./voting.sol";
import "./registration.sol";
import "./candidate.sol";
import "./Nomination.sol";

contract ElectionFacade {

    address public AddresssToVoting;
    address public AddressToregistration;
    address public AddressToNomination;
    address private creatoraddress;
    Phase public currentPhase = Phase.pre_election;
    enum Phase {pre_election, first_turn, second_turn, post_election}

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

    constructor(address _AddresssToVoting, address _AddressToregistration) {
        creatoraddress = msg.sender;
        AddresssToVoting = _AddresssToVoting;
        AddressToregistration = _AddressToregistration;
    }
    // Registration
    function register() onlyPreElection external {
        registration(AddressToregistration).register();
    }

    // Nominations
    function nominate(address newNominee, string calldata firstName, string calldata lastName) haveVotingPower onlyPreElection external {
        registration(AddressToNomination).nominate(newNominee, firstName, lastName);
    }

    function endorse(address from, address nominee) haveVotingPower onlyPreElection external {
        registration(AddressToNomination).endorse(from, nominee);
    }
    // Voting

    function StartFirstTurn() internal
    {
        require(creatoraddress == msg.sender, "Only creator can change phase");
        registration(AddressToregistration).endRegistrationPhase();
        currentPhase = Phase.first_turn;
    }

    function StartSecondTurn() internal
    {
        require(creatoraddress == msg.sender, "Only creator can change phase");
        /// TODO add end of first turn logic
        currentPhase = Phase.second_turn;
    }
    function endElection() internal
    {
        require(creatoraddress == msg.sender, "Only creator can change phase");
        voting(AddresssToVoting).endvoting();
    }

    function vote(address candidate) haveVotingPower onlyFirstTurn external 
    {
        if (currentPhase == Phase.first_turn)
        {
            voting(AddresssToVoting).vote(candidate);
        }
        else if (currentPhase == Phase.second_turn)
        {
            voting(AddresssToVoting).voteSecondTurn(candidate);
        }
    }

    // View functions
    function getCandidate(address candidate) public view returns (int, string memory, string memory, address) 
    {
        return Voting(AddresssToVoting).getCandidate(candidate);
    }

    function getVotesSecondTurn(address candidate) public view returns (int) {
        return Voting(AddresssToVoting).getVotesSecondTurn(candidate);
    }

    function getVotes(address candidate) public view returns (int) {
        return Voting(AddresssToVoting).getVotes(candidate);
    }

    function isParticipantRegistered(address participantAddress) public view returns (bool) {
        return registration(AddressToregistration).isParticipantRegistered(participantAddress);
    }
}
