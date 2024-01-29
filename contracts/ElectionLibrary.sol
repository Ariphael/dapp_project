// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Define the Candidate struct in a separate file
struct Candidate {
    int id;
    string firstName;
    string lastName;
    address candidateAddress;
    uint64 votesFirstTurn;
    uint64 votesSecondTurn;
}
