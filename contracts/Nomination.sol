// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.20;

contract Nomination {
  enum NominationParticipantStatus { Nominee, Candidate }

  uint private constant MINIMUM_REQUIRED_ENDORSEMENTS = 5;

  mapping(address => uint) nomineeEndorsements;
  mapping(address => mapping(address => bool)) participantEndorsementRecord;
  mapping(address => NominationParticipant) nominationParticipantInfo;
  address private electionContractAddress;
  int private nextId;
  address[] public allCandidates;
  mapping(address => bool) public isCandidate;

  /// @dev This emits when a new nominee is created.
  event Nominate(address nominee);

  /// @dev This emits when a nominee turns into a candidate which occurs when a sufficient number of endorsements
  /// is accrued. 
  /// Note: Nominee endorsements for the address nominee resets to zero and a candidate cannot be nominated.
  event NewCandidate(address nominee);

  /// @dev This emits when a nominee receives an endorsement.
  event Endorsement(address nominee, uint newEndorsementCount);

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    /// # todo: change to election contract only
    _;
  }

  constructor(address electionContractAddressParam) {
    electionContractAddress = electionContractAddressParam;
    nextId = 1;
  }

  struct NominationParticipant 
  {
    int id;
    string firstName;
    string lastName;
    NominationParticipantStatus status;
  }

  function nominate(address newNominee, string calldata firstName, string calldata lastName) external onlyElectionContractCanCall {
    require(!isContract(newNominee), "Operation denied. A contract account cannot be nominated as candidate");
    require(nominationParticipantInfo[newNominee].id == 0, "Operation denied. Account is already a candidate or nominee");

    nomineeEndorsements[newNominee] = 1;
    nominationParticipantInfo[newNominee] =
      NominationParticipant(nextId, firstName, lastName, NominationParticipantStatus.Nominee);
    nextId++;
    emit Nominate(newNominee);
  }

  function endorse(address from, address nominee) external onlyElectionContractCanCall {
    require(from != address(0), "Operation denied. From cannot be the address zero.");
    require(nomineeEndorsements[from] != 0, "Operation denied. \"nominee\" is not a nominee.");
    require(participantEndorsementRecord[from][nominee] == false, "Operation denied. From cannot endorse the same nominee more than once.");

    /// TODO Check if participant can endorse
    nomineeEndorsements[nominee]++;
    participantEndorsementRecord[from][nominee] = true;
    emit Endorsement(nominee, nomineeEndorsements[nominee]);

    // Check if nominated
    if (isCandidate[nominee] == false) 
      {
      if (nomineeEndorsements[nominee] >= MINIMUM_REQUIRED_ENDORSEMENTS){
      nomineeEndorsements[nominee] = 0;
      nominationParticipantInfo[nominee].status = NominationParticipantStatus.Candidate;
      allCandidates.push(nominee);
      isCandidate[nominee] = true;
      emit NewCandidate(nominee);
      }
    }
  }

  function getCandidateInfo(address candidate) external view returns (NominationParticipant memory) {
    require(
      nominationParticipantInfo[candidate].id != 0 
        && nominationParticipantInfo[candidate].status == NominationParticipantStatus.Candidate, 
      "Operation denied. Account is not a candidate."
    );
    return nominationParticipantInfo[candidate];
  }
  function getAllCandidatesAdresses() external view returns (address[] memory) {
    return allCandidates;
  }

  function isContract(address account) private view returns (bool) {
    uint32 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}