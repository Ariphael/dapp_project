import "./secondSC.sol";
import "./registration.sol";
import "./candidate.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

contract ElectionFacade {

    address public AddresssTosecondSC;
    address public AddressToregistration;
    // secondSC private election;
    // registration private registrationContract;
    address private creatoraddress;
    constructor(address _AddresssTosecondSC, address _AddressToregistration) {
        //registrationContract = new registration(address(this));
        creatoraddress = msg.sender;
        AddresssTosecondSC = _AddresssTosecondSC;
        AddressToregistration = _AddressToregistration;
    }

    function register() external {
        registration(AddressToregistration).register();
    }

    function isParticipantRegistered(address participantAddress) public view returns (bool) {
        return registration(AddressToregistration).isParticipantRegistered(participantAddress);
    }

    function vote(address candidate) external {
        secondSC(AddresssTosecondSC).vote(candidate);
    }

    function getVotes(address candidate) public view returns (int) {
        return secondSC(AddresssTosecondSC).getVotes(candidate);
    }

    function getCandidate(address candidate) public view returns (int, string memory, string memory, address) {
        return secondSC(AddresssTosecondSC).getCandidate(candidate);
    }

    function endRegistrationPhase() public {
        require(creatoraddress == msg.sender, "Only creator can end registration phase");
        
        registration(AddressToregistration).endRegistrationPhase();
        // Candidate[] memory candidates = new Candidate[](2);
        // candidates[0] = Candidate(1, "John", "Doe", address(0x123), 0, 0);
        // candidates[1] = Candidate(2, "Jane", "Smith", address(0x456), 0, 0);
        // election = new secondSC(candidates);
    }

}