// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract DecisionVoting {

    struct Voting {
        address votingOwner;
        string votingPurpose;
        uint endTime;
        uint[] optionVotes; // Array to store votes for each option
        string[] options;
        mapping(address => bool) hasVoted; // Track if an address has voted
        address[] voters; // List of addresses entitled to vote
    }

    mapping(uint => Voting) public polls;
    uint public countPolls;

    constructor() {
        countPolls = 0;
    }

    // Function to create a new poll with eligible voters
    function createNewVoting(string memory purpose, uint endTime, uint options, address[] memory eligibleVoters , string[] memory optionsinput) public {
        require(options > 0, "There must be at least one option.");
        require(eligibleVoters.length > 0, "There must be at least one eligible voter.");

        Voting storage newVoting = polls[countPolls];
        newVoting.votingOwner = msg.sender;
        newVoting.votingPurpose = purpose;
        newVoting.endTime = endTime;
        newVoting.optionVotes = new uint[](options);
        newVoting.voters = eligibleVoters;
        newVoting.options = optionsinput;

        for(uint i = 0; i < options; i++) {
            newVoting.optionVotes[i] = 0; // Initialize all option votes to 0
        }

        countPolls++;
    }

    // Function for eligible voters to cast their votes
    function castVote(uint pollId, uint option) public {
        Voting storage poll = polls[pollId];
        require(block.timestamp <= poll.endTime, "Voting is not active.");
        require(isVoterEligible(pollId, msg.sender), "You are not eligible to vote in this poll.");
        require(!poll.hasVoted[msg.sender], "You have already voted.");
        require(option < poll.optionVotes.length, "Invalid option.");

        poll.optionVotes[option]++;
        poll.hasVoted[msg.sender] = true;

    }

    // Helper function to check if an address is eligible to vote in a poll
    function isVoterEligible(uint pollId, address voter) private view returns (bool) {
        Voting storage poll = polls[pollId];
        for(uint i = 0; i < poll.voters.length; i++) {
            if(poll.voters[i] == voter) {
                return true;
            }
        }
        return false;
    }

    // Function to check the result of a poll
    function checkPollResult(uint pollId) public view returns (uint winningOption , uint[] memory) {
        Voting storage poll = polls[pollId];
        require(block.timestamp > poll.endTime, "Poll is still open.");

        uint maxVotes = 0;
        for (uint i = 0; i < poll.optionVotes.length; i++) {
            if (poll.optionVotes[i] > maxVotes) {
                winningOption = i;
                maxVotes = poll.optionVotes[i];
            }
        }
        return ( winningOption , poll.optionVotes );
    }

    //for currently active
    function checkPollStatus(uint pollId) public view returns (uint[] memory) {
        Voting storage poll = polls[pollId];
        uint maxVotes = 0;
        return poll.optionVotes;
    }
    
    function infoAboutVoting(uint pollId) public view returns (address owner , string memory purpose , uint etime , uint[] memory , string[] memory ) {
        return (polls[pollId].votingOwner ,polls[pollId].votingPurpose ,polls[pollId].endTime ,polls[pollId].optionVotes ,polls[pollId].options);
    }

    function getNoOfPolls() public view returns (uint num) {
        return countPolls;
    }
    
}
