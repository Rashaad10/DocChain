// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract ClaimsContract {
    
    // Define a claim structure
    struct Claim {
        string field;
        string value;
        address issuer; // address of the issuer
    }

    // Define a user structure
    struct User {
        bool exists;
        Claim[] claims; // Array of claims
    }
    
    event ClaimMade(address indexed claimedUser, string field, string value, address issuer);

    uint public totalUser;
    // Mapping from an address to a user
    mapping(address => User) public users;

    // Function to add a new user
    function addUser(address userAddress) public {
        require(!users[userAddress].exists, "User already exists");
        users[userAddress].exists = true;
        totalUser++;

    }

    //get total number of User
    function getNoOfUser() public view returns(uint){
        return totalUser;
    }
    
    // Function to make a claim about a user
    function makeClaim(address userAddress, string memory field, string memory value) public {
        require(users[userAddress].exists, "User does not exist");

        // Create a new claim
        Claim memory newClaim = Claim({
            field: field,
            value: value,
            issuer: msg.sender
        });

        // Add the claim to the user's claims
        users[userAddress].claims.push(newClaim);

        emit ClaimMade(userAddress, field, value, msg.sender);
    }

    // Function to get the number of claims a user has
    function getClaimsCount(address userAddress) public view returns (uint) {
        require(users[userAddress].exists, "User does not exist");
        return users[userAddress].claims.length;
    }

    //function to return all the claims of a user
    
    // Function to return all claims of a user
    function getAllClaims(address userAddress) public view returns (string[] memory, string[] memory, address[] memory) {
        require(users[userAddress].exists, "User does not exist");

        uint claimCount = users[userAddress].claims.length;

        // Initialize arrays to hold the claim data
        string[] memory fields = new string[](claimCount);
        string[] memory values = new string[](claimCount);
        address[] memory issuers = new address[](claimCount);

        // Populate the arrays
        for (uint i = 0; i < claimCount; i++) {
            Claim storage claim = users[userAddress].claims[i];
            fields[i] = claim.field;
            values[i] = claim.value;
            issuers[i] = claim.issuer;
        }

        return (fields, values, issuers);
    }   
}
