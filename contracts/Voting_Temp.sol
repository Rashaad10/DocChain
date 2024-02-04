// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

contract DecisionVoting {

    // Define a user structure
    struct User {
        bool exists;
        uint votes;
        uint votedOption; // Option selected by the user
    }

    // Define a voting structure
    struct Voting {
        address votingOwner;
        string votingPurpose;
        uint startTime;
        uint endTime;
        bool isOpen;
        uint[] optionVotes; // Array to store votes for each option
        mapping(address => bool) hasVoted;
        mapping(address => User) users;
    }

    Voting public currentVoting;

    // Event to announce the end of the voting period and reveal results
    event VotingResult(uint[] optionVotes, string result);
    event VotingStarted(string message);
    event VotingEnded(string message);
    event WinnerDeclared(uint winningOption, uint maxVotes);

    // Function to add a user to the contract
    function addUser(address userAddress) public {
        require(!currentVoting.isOpen, "Voting is open, cannot add users now");
        require(!currentVoting.users[userAddress].exists, "User already added");

        currentVoting.users[userAddress] = User(true, 0, 0); // Initialize voted option to 0
        currentVoting.hasVoted[userAddress] = false; // Reset hasVoted status
    }

    // Function to start a new voting
    function startVoting(string memory votingPurpose, uint durationInMinutes, uint numOptions) public {
        require(!currentVoting.isOpen, "Voting is already open");
        require(numOptions > 0, "Number of options should be greater than 0");

        // Set up the new voting
        currentVoting.votingOwner = msg.sender;
        currentVoting.votingPurpose = votingPurpose;
        currentVoting.startTime = block.timestamp;
        currentVoting.endTime = block.timestamp + durationInMinutes * 1 minutes;
        currentVoting.isOpen = true;

        // Initialize optionVotes array with zeros
        currentVoting.optionVotes = new uint[](numOptions);

        // Emit an event to inform users about the new voting
        emit VotingStarted(string(abi.encodePacked("Voting for '", currentVoting.votingPurpose, "' has started. Cast your votes!")));
    }

    // Function to vote for a specific option
    function vote(uint selectedOption) public {
        require(currentVoting.isOpen, "Voting is not open");
        require(!currentVoting.hasVoted[msg.sender], "You have already voted");
        require(currentVoting.users[msg.sender].exists, "You are not a registered user");
        require(selectedOption > 0 && selectedOption <= currentVoting.optionVotes.length, "Invalid option");

        // Update the voting status and counts
        currentVoting.optionVotes[selectedOption - 1]++; // Options are 1-indexed
        currentVoting.hasVoted[msg.sender] = true;
        currentVoting.users[msg.sender].votes++;
        currentVoting.users[msg.sender].votedOption = selectedOption;
    }

    // Function to end voting and determine the result
    function endVoting() public {
        require(currentVoting.isOpen, "Voting is not open");
        require(msg.sender == currentVoting.votingOwner, "Only the voting owner can end the voting");

        // Close the voting
        currentVoting.isOpen = false;

        // Emit an event to reveal the results
        emit VotingEnded("Voting has ended.");

        // Emit an event to declare the winner
        emit WinnerDeclared(getWinner(), getMaxVotes());
    }

    // Function to get the winner
    function getWinner() public view returns (uint) {
        uint maxVotes = 0;
        uint winningOption = 0;

        for (uint i = 0; i < currentVoting.optionVotes.length; i++) {
            if (currentVoting.optionVotes[i] > maxVotes) {
                maxVotes = currentVoting.optionVotes[i];
                winningOption = i + 1; // Options are 1-indexed
            }
        }

        return winningOption;
    }

    // Function to get the maximum votes
    function getMaxVotes() public view returns (uint) {
        uint maxVotes = 0;

        for (uint i = 0; i < currentVoting.optionVotes.length; i++) {
            if (currentVoting.optionVotes[i] > maxVotes) {
                maxVotes = currentVoting.optionVotes[i];
            }
        }

        return maxVotes;
    }

    // Function to get the current voting details
    function getCurrentVoting() public view returns (string memory, uint, uint, bool, uint[] memory) {
        return (
            currentVoting.votingPurpose,
            currentVoting.startTime,
            currentVoting.endTime,
            currentVoting.isOpen,
            currentVoting.optionVotes
        );
    }
    
}