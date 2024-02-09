// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract AccessSecuritySystem {

    // Struct to represent a user
    struct User {
        bool exists;
        mapping(uint => uint) propertyToAccessExpiry; // Mapping from property ID to access expiry time
        uint[] ownedProperties; // List of properties owned by the user
        uint[] tempProperties;
    }

    // Struct to represent a property
    struct Property {
        bool exists;
        address mainOwner; // Address of the main owner of the property
        mapping(address => uint) accessExpiry; // Mapping from user's address to access expiry time
        address[] usersWithAccess; // List of users with access to the property
        address[] usersWhoAccessed; // List of users who accessed the property
        uint[] timeUsersWhoAccessed;
    }

    mapping(address => User) public users; // Mapping from user's address to User struct
    mapping(uint => Property) public properties; // Mapping from property ID to Property struct

    // Function to add a new property to the system
    function addProperty(uint propertyId, address mainOwner) public {
        users[mainOwner].exists = true;
        require(!properties[propertyId].exists, "Property already exists");
        require(users[mainOwner].exists, "Main owner does not exist, add user first");

        properties[propertyId].exists = true;
        properties[propertyId].mainOwner = mainOwner;
        users[mainOwner].ownedProperties.push(propertyId);
    }

    // Function to add a user into the system
    /*function addUser(address userAddress) public {
        require(!users[userAddress].exists, "User already exists");
        users[userAddress].exists = true;
    }*/

    // Function to transfer access of a property to another user
    function grantAccess(uint propertyId, address to, uint accessExpiryMinutes) public {
        users[to].exists = true;
        require(properties[propertyId].exists, "Property does not exist");
        require(users[msg.sender].exists, "Sender user does not exist");
        require(users[to].exists, "Receiver user does not exist");
        require(isPropertyOwner(msg.sender, propertyId), "Sender is not the owner of the property");

        // Grant access to the new user
        properties[propertyId].usersWithAccess.push(to);
        properties[propertyId].accessExpiry[to] = block.timestamp + accessExpiryMinutes * 1 minutes;
        users[to].tempProperties.push(propertyId);
    }

    // Function to check if a user owns a specific property
    function isPropertyOwner(address user, uint propertyId) internal view returns (bool) {
        for (uint i = 0; i < users[user].ownedProperties.length; i++) {
            if (users[user].ownedProperties[i] == propertyId) {
                return true;
            }
        }
        return false;
    }

    // Function to check if a user has access to a property at the current time
    //with function checkAccess, person enters the property
   
    function userEnter(address user, uint propertyId) public{
        require(users[user].exists, "User does not exist");
        require(properties[propertyId].exists, "Property does not exist");

        // Check if the user is the main owner or has been granted access
        if (user == properties[propertyId].mainOwner) {
            // Add user to the list of users who accessed the property
            properties[propertyId].usersWhoAccessed.push(user);
            properties[propertyId].timeUsersWhoAccessed.push(block.timestamp);
        }

        // Check if the user has been granted access
        uint expiryTime = properties[propertyId].accessExpiry[user];
        if (block.timestamp <= expiryTime) {
            // Add user to the list of users who accessed the property
            properties[propertyId].usersWhoAccessed.push(user);
            properties[propertyId].timeUsersWhoAccessed.push(block.timestamp);
        }
    }
    
     function checkAccess(address user, uint propertyId) public view returns (bool) {
        // require(users[user].exists, "User does not exist");
        if (!users[user].exists || !properties[propertyId].exists) {
            return false;
        } 
        // Check if the user is the main owner or has been granted access
        if (user == properties[propertyId].mainOwner) {
            return true;
        }

        // Check if the user has been granted access
        uint expiryTime = properties[propertyId].accessExpiry[user];
        if (block.timestamp <= expiryTime) {
            // Add user to the list of users who accessed the property
            return true;
        }

        return false;
    }
      function tempOwnerData(uint propertyId)public view returns(address mainOwner,uint expiryTime)
     {
        require(properties[propertyId].accessExpiry[msg.sender]>0,"User is not entitled to see this");
        return (properties[propertyId].mainOwner,properties[propertyId].accessExpiry[msg.sender]);
    }
    
    // Function to read properties owned by a user
    function readUserProperties(address user) public view returns (uint[] memory) {
        return users[user].ownedProperties;
    }

    // Function to read all the temporary properties of user
    function readTempProperties(address user) public view returns (uint[] memory) {
        return users[user].tempProperties;
    }

    // Function to get property details
    function propertyDetails(uint propertyId) public view returns (
        address mainOwner,
        address[] memory usersWithAccess,
        uint[] memory accessExpiry,
        address[] memory usersWhoAccessed,
        uint[] memory timeUsersWhoAccesssed
    ) {
        require(properties[propertyId].exists, "Property does not exist");
        require(msg.sender == properties[propertyId].mainOwner , "User is not entitled for this");
        mainOwner = properties[propertyId].mainOwner;
        usersWithAccess = properties[propertyId].usersWithAccess;
        uint length = usersWithAccess.length;
        accessExpiry = new uint[](length);
        for (uint i = 0; i < length; i++) {
            accessExpiry[i] = properties[propertyId].accessExpiry[usersWithAccess[i]];
        }
        usersWhoAccessed = properties[propertyId].usersWhoAccessed;
        timeUsersWhoAccesssed = properties[propertyId].timeUsersWhoAccessed;

        return(mainOwner, usersWithAccess, accessExpiry, usersWhoAccessed, timeUsersWhoAccesssed);
    }
}