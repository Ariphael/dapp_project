pragma solidity ^0.8.20;

import "./secondSC.sol"; 

contract Results{
    address public secondSCContract;
    address public winner;
    bool public twoTurnsCompleted;

    //event to notify when the two turns are completed
    event TwoTurnsCompleted(address winner);

    modifier onlySecondSCContractCanCall() {
        require(msg.sender == secondSCContract, "Permission denied");
        _;
    }

    constructor(address _secondSCContract) {
        secondSCContract = _secondSCContract;
    }

    function executeTurns() external onlySecondSCContractCanCall {
        require(!twoTurnsCompleted, "Two turns already completed");

        //get the results from the secondSC contract
        (uint256 totalVotes, address firstPlace, address secondPlace) = getElectionResults();

        //check if any candidate got the majority of votes
        if (totalVotes > 0) {
            uint256 majorityThreshold = (totalVotes * 50) / 100;

            if (numberOfVotes[firstPlace] >= majorityThreshold && !isWinner[firstPlace]) {
                //first candidate won in the current round
                winner = firstPlace;
                isWinner[winner] = true;
                twoTurnsCompleted = true;
                emit TwoTurnsCompleted(winner);
            }

            //SECOND TURN
            } else {

            }
        }

    //function to get the results from the secondSC contract
    function getElectionResults() internal view returns (uint256, address, address) {
        //instance of the secondSC contract
        secondSC secondSCInstance = secondSC(secondSCContract);

        address[] memory candidateList = getCandidateListFromSecondSC();

        //initialize variables to hold total votes and top two candidates
        uint256 totalVotes = 0;
        address firstPlace;
        address secondPlace;

        //loop the candidate list to get votes and determine top two candidates
        for (uint256 i = 0; i < candidateList.length; i++) {
            address candidate = candidateList[i];
            int votes = secondSCInstance.getVotes(candidate);

            totalVotes += uint256(votes);

            if (votes > numberOfVotes[firstPlace]) {
                secondPlace = firstPlace;
                firstPlace = candidate;
            }

            else if (votes > numberOfVotes[secondPlace]) {
                secondPlace = candidate;
            }
        }

        return (totalVotes, firstPlace, secondPlace);
    }

    //function to get the list of candidates from the secondSC contract
    function getCandidateListFromSecondSC() internal view returns (address[] memory) {
        //instance of the secondSC contract
        secondSC secondSCInstance = secondSC(secondSCContract);

        //if secondSC has a getCandidateList function
        return secondSCInstance.getCandidateList();

    }
}

