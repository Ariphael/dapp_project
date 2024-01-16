// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.20;

contract Nomination {
  uint private constant MINIMUM_REQUIRED_ENDORSEMENTS = 5;

  mapping(address => uint) nomineeEndorsements;
  mapping(address => Candidate) candidates;
  address private electionContractAddress;

  /// @dev This emits when a new nominee is created.
  event Nominate(address nominee);

  /// @dev This emits when a nominee turns into a candidate which occurs when a sufficient number of endorsements
  /// is accrued.
  event Candidate(address nominee);

  /// @dev This emits when a nominee receives an endorsement.
  event Endorsement(address nominee, uint newEndorsementCount);

  modifier onlyElectionContractCanCall() {
    require(msg.sender == electionContractAddress);
    _;
  }

  struct Candidate {
    int id;
    string firstName;
    string lastName;
    address candidateAddress;
  }

  function nominate(address newNominee) onlyElectionContractCanCall external {
    require(!isContract(newNominee), "Operation denied. A contract account cannot be nominated as candidate");
    require(isZero(candidates[newNominee]), "Operation denied. Account is already a candidate");
    require(nomineeEndorsements[newNominee] == 0, "Operation denied. Account is already a nominee.");

    nomineeEndorsements[newNominee] = 1;
    emit Nominate(newNominee);
  }

  function endorse(address from, address nominee) onlyElectionContractCanCall external {
    require(from != address(0), "Operation denied. From cannot be the address address.");
    require(nomineeEndorsements[from] != 0, "Operation denied. \"nominee\" is not a nominee.");

    nomineeEndorsements[nominee]++;
    emit Endorsement(nominee, nomineeEndorsements[nominee]);

    if (nomineeEndorsements[nominee] >= MINIMUM_REQUIRED_ENDORSEMENTS) {
      // TODO
    }
  }

  function isZero(Candidate memory candidate) private pure returns (bool) {
    return candidate.id == 0 
      && keccak256(bytes(candidate.firstName)) == keccak256(bytes(""))
      && keccak256(bytes(candidate.lastName)) == keccak256(bytes("")) 
      && candidate.candidateAddress == address(0);
  }

  function isContract(address account) private view returns (bool) {
    uint32 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}