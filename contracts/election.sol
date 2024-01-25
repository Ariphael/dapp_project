// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "./voting.sol";
import "./registration.sol";
import "./candidate.sol";

contract ElectionFacade {

    address public AddresssToVoting;
    address public AddressToregistration;
    address private creatoraddress;

    constructor(address _AddresssToVoting, address _AddressToregistration) {
        creatoraddress = msg.sender;
        AddresssToVoting = _AddresssToVoting;
        AddressToregistration = _AddressToregistration;
    }

    function register() external {
        registration(AddressToregistration).register();
    }

    function isParticipantRegistered(address participantAddress) public view returns (bool) {
        return registration(AddressToregistration).isParticipantRegistered(participantAddress);
    }

    function vote(address candidate) external {
        Voting(AddresssToVoting).vote(candidate);
    }

    function getVotes(address candidate) public view returns (int) {
        return Voting(AddresssToVoting).getVotes(candidate);
    }

    function voteSecondTurn(address candidate) external {
        Voting(AddresssToVoting).voteSecondTurn(candidate);
    }

    function getVotesSecondTurn(address candidate) public view returns (int) {
        return Voting(AddresssToVoting).getVotesSecondTurn(candidate);
    }

    function getCandidate(address candidate) public view returns (int, string memory, string memory, address) {
        return Voting(AddresssToVoting).getCandidate(candidate);
    }

    function endRegistrationPhase() public {
        require(creatoraddress == msg.sender, "Only creator can end registration phase");
        registration(AddressToregistration).endRegistrationPhase();
    }
}
