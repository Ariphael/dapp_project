import "./secondSC.sol";
import "./registration.sol";
import "./candidate.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

contract ElectionFacade {
    secondSC private election;
    registration private registrationContract;
    address private creatoraddress;
    constructor() {
        registrationContract = new registration(address(this));
        creatoraddress = msg.sender;
    }

    function register() external {
        registrationContract.register();
    }

    function isParticipantRegistered(address participantAddress) public view returns (bool) {
        return registrationContract.isParticipantRegistered(participantAddress);
    }

    function vote(address candidate) external {
        election.vote(candidate);
    }

    function getVotes(address candidate) public view returns (int) {
        return election.getVotes(candidate);
    }

    function getCandidate(address candidate) public view returns (int, string memory, string memory, address) {
        return election.getCandidate(candidate);
    }

    function endRegistrationPhase() public {
        require(creatoraddress == msg.sender, "Only creator can end registration phase");
        
        registrationContract.endRegistrationPhase();
        Candidate[] memory candidates = new Candidate[](2);
        candidates[0] = Candidate(1, "John", "Doe", address(0x123));
        candidates[1] = Candidate(2, "Jane", "Smith", address(0x456));
        election = new secondSC(candidates);
    }

}