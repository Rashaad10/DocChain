// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract ClaimsContract {
    // Define a claim structure
    struct Claim {
        string field;
        string value;
        address issuer; // address of the issuer
    }

    //Define a requestedClaim structure
    struct RequestedClaim {
        string field;
        string value;
        address requestTo;
        address requestBy;
        bool requested;
    }

    struct RequestedInfo {
        string field;
        address requestedBy;
        bool answered;
    }

    struct ReceivedInfo{
        Claim claim;
        address sender;
    }

    // Define a user structure
    struct User {
        bool exists;
        uint no_of_requests;
        Claim[] claims; // Array of claims
        mapping(string => Claim) feildClaims;
        mapping(uint => RequestedInfo) inforequests; //request of others who want my information // all the requests from me
        RequestedClaim[] reqclaims; // the claims that I requested for
        RequestedClaim[] reqfrommeclaims; //the claims that was requested from me
        ReceivedInfo[] recinfos; //all the information I recieved from others
        uint noOfHash;
        string[] documentHash;
        mapping(string => address) documentIssuer;
    } 

    event UserAdded(
        address user
    );
    event ClaimMade(
        address indexed claimedUser,
        string field,
        address issuer
    );
    event ClaimRequested(
        address indexed requestBy,
        address indexed requestTo
    );
    // Event to notify when a field information request is made
    event FieldInfoRequested(
        address requestFrom,
        address requestTo,
        string field
    );

    event FieldInfoRecieved(
        address recievedBy,
        address sendBy
    );

    uint private totalUser;
    // Mapping from an address to a user
    mapping(address => User) private users;
    // mapping(uint => RequestedClaim) private requests;
    // uint private countRequests;

    event Yourid(
        address Youraddress
    );
    function showUser() public {
        emit Yourid(msg.sender);
    }

    // Function to add a new user
    function addUser(address userAddress) public {
        require(!users[userAddress].exists, "User already exists");
        users[userAddress].exists = true;
        totalUser++;
        emit UserAdded(userAddress);
    }

    //get total number of User
    function getNoOfUser() public view returns (uint) {
        return totalUser;
    }

    //function to request a claim from the user
    function requestClaim(
        address userAddress,
        string memory field,
        string memory value
    ) public {
        require(users[userAddress].exists, "User does not exist");

        RequestedClaim memory newReqClaim = RequestedClaim({
            field: field,
            value: value,
            requestTo: userAddress,
            requestBy: msg.sender,
            requested: true
        });

        users[msg.sender].reqclaims.push(newReqClaim);
        users[userAddress].reqfrommeclaims.push(newReqClaim);
        // requests[countRequests] = newReqClaim;

        emit ClaimRequested(msg.sender, userAddress);

        // countRequests++;
    }

    // Function to make a claim about a user
    function makeClaim(
        address userAddress,
        string memory field,
        string memory value
    ) public {
        require(users[userAddress].exists, "User does not exist");

        // Create a new claim
        Claim memory newClaim = Claim({
            field: field,
            value: value,
            issuer: msg.sender
        });

        users[userAddress].feildClaims[field] = newClaim;

        // Add the claim to the user's claims
        users[userAddress].claims.push(newClaim);

        emit ClaimMade(userAddress, field , msg.sender);
    }

    // Function to get the number of claims a user has
    function getClaimsCount(address userAddress) public view returns (uint) {
        require(
            msg.sender == userAddress,
            "You are not entitled for calling this function"
        );
        require(users[userAddress].exists, "User does not exist");
        return users[userAddress].claims.length;
    }

    //event called when someone calls getAllClaims
    // event getAllClaimscalled(
    //     address userAdress
    // );

    // Function to return all claims of a user
    function getAllClaims() public view returns (string[] memory, string[] memory, address[] memory) {
        address userAddress = msg.sender;
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
        // emit getAllClaimscalled(userAddress);
        return (fields, values, issuers);
    }

    //Functioin to get the count of claims that user requested
    function getRequestedClaimsCount(address userAddress) public view returns (uint) {
        require( msg.sender == userAddress,"You are not entitled for calling this function");
        require(users[userAddress].exists, "User does not exist");
        return users[userAddress].reqclaims.length;
    }

    // event getAllReqClaimsCalled(
    //     address userAddress
    // );
    //Function to get all the claims that user has requested
    function getAllReqClaims() public view returns (string[] memory, string[] memory, address[] memory, bool[] memory) {
        address userAddress = msg.sender;
        // emit getAllReqClaimsCalled(msg.sender);
        require(users[userAddress].exists, "User does not exist");
        uint reqClaimCount = users[userAddress].reqclaims.length;

        // Initialize arrays to hold the claim data
        string[] memory fields = new string[](reqClaimCount);
        string[] memory values = new string[](reqClaimCount);
        address[] memory issuers = new address[](reqClaimCount);
        bool[] memory status = new bool[](reqClaimCount);

        // Populate the arrays
        for (uint i = 0; i < reqClaimCount; i++) {
            RequestedClaim storage reqclaim = users[userAddress].reqclaims[i];
            fields[i] = reqclaim.field;
            values[i] = reqclaim.value;
            issuers[i] = reqclaim.requestBy;
            status[i] = reqclaim.requested;
        }

        return (fields, values, issuers, status);
    }

    //Function to get the count of all the reqclaims that was requested from the user
    function getReqFromMeClaimsCount(address userAddress) public view returns (uint) {
        require( msg.sender == userAddress, "You are not entitled for calling this function");
        require(users[userAddress].exists, "User does not exist");
        return users[userAddress].reqfrommeclaims.length;
    }

    //Function to get all the claims that was requested from user
    function getAllReqFromMeClaims() public view returns (string[] memory, string[] memory, address[] memory, bool[] memory) {
        address userAddress = msg.sender;
        // emit getAllReqFromMeClaimsCalled(userAddress);
        require(users[userAddress].exists, "User does not exist");
        uint reqFromMeClaimCount = users[userAddress].reqfrommeclaims.length;

        // Initialize arrays to hold the claim data
        string[] memory fields = new string[](reqFromMeClaimCount);
        string[] memory values = new string[](reqFromMeClaimCount);
        address[] memory issuers = new address[](reqFromMeClaimCount);
        bool[] memory status = new bool[](reqFromMeClaimCount);

        
        for (uint i = 0; i < reqFromMeClaimCount; i++) {
            RequestedClaim storage reqfrommeclaim = users[userAddress].reqfrommeclaims[i];
            fields[i] = reqfrommeclaim.field;
            values[i] = reqfrommeclaim.value;
            issuers[i] = reqfrommeclaim.requestTo;
            status[i] = reqfrommeclaim.requested;
        }

        return (fields, values, issuers, status);
    }

    event requestAnswered(
        address requester,
        address answerer
    );

    //indexOfQuery refers to indexing of request in reqfrommeclaims
    //this will automatically call makeClaim function
    function answeringRequestedClaim(uint indexOfQuery, uint num) public {
    if (num == 1) {
            // Response to claim request with num = 1
            require(indexOfQuery < users[msg.sender].reqfrommeclaims.length, "Invalid index");

            // Set requested to false for the claim in the requester's array
            users[msg.sender].reqfrommeclaims[indexOfQuery].requested = false;

            // Retrieve information about the claim
            address userAddress = users[msg.sender].reqclaims[indexOfQuery].requestBy;
            string memory field = users[msg.sender].reqclaims[indexOfQuery].field;
            string memory value = users[msg.sender].reqclaims[indexOfQuery].value;

            // Find the corresponding claim in the requester's array and set requested to false
            uint maxLen = users[userAddress].reqclaims.length;
            uint index;

            for (uint i = 0; i < maxLen; i++) {
                if (users[userAddress].reqclaims[i].requestBy == msg.sender &&
                    keccak256(abi.encodePacked(users[userAddress].reqclaims[i].field)) == keccak256(abi.encodePacked(field)) &&
                    keccak256(abi.encodePacked(users[userAddress].reqclaims[i].value)) == keccak256(abi.encodePacked(value))
                ) {
                    index = i;
                    break;
                }
            }

            // Set requested to false for the corresponding claim in the requester's array
            if (index < maxLen) {
                users[userAddress].reqclaims[index].requested = false;
                
                // Make the claim for the requester
                makeClaim(userAddress, field, value);
            }
            emit requestAnswered(userAddress, msg.sender);
        } else {
            // Response to claim request with num not equal to 1
            require(indexOfQuery < users[msg.sender].reqfrommeclaims.length, "Invalid index");
            address userAddress = users[msg.sender].reqclaims[indexOfQuery].requestBy;
            users[msg.sender].reqfrommeclaims[indexOfQuery].requested = false;
            emit requestAnswered(userAddress, msg.sender);
        }


    }

    // Function to request the field's value from another user and return the claim made
    function reqFieldInfo(address userAddress,string memory field) public returns (Claim memory) {
        require(users[userAddress].exists, "User does not exist");

        RequestedInfo memory newRequestedInfo = RequestedInfo({
            field: field,
            requestedBy: msg.sender,
            answered: false
        });

        users[userAddress].inforequests[users[userAddress].no_of_requests] = newRequestedInfo;
        users[userAddress].no_of_requests++;

        // Emit an event to notify the request
        emit FieldInfoRequested(msg.sender, userAddress, field);
        return users[userAddress].feildClaims[field];
    }

    // Function to get all the info field requested from me
    function getAllFieldRequestFromMe() public view returns(string[] memory, address[] memory, bool[] memory){
        address userAddress = msg.sender;
        uint n = users[userAddress].no_of_requests;
        string[] memory field = new string[](n);
        address[] memory requestedBy = new address[](n);
        bool[] memory answer = new bool[](n);
        for(uint i=0;i<n;i++)
        {
            field[i] = users[userAddress].inforequests[i].field;
            requestedBy[i] = users[userAddress].inforequests[i].requestedBy;
            answer[i] = users[userAddress].inforequests[i].answered;
        }
        return (field , requestedBy , answer);
    }
    //I am not showing whatever requests I have made from another user.

    //function to both answer the request and deny the request
    //if num==1 than I will answer the query otherwise deny the query
    function ansRequestFieldInfo(uint indexOfQuery , uint num)public { 
        require(users[msg.sender].inforequests[indexOfQuery].requestedBy != address(0), "Request does not exist");      
        users[msg.sender].inforequests[indexOfQuery].answered = true; //this means that request is answered
        require(num == 1, "Requested Denied");
        //msg.sender seh user Address pr feild send
        RequestedInfo storage reqInfo = users[msg.sender].inforequests[indexOfQuery];
        string memory field = reqInfo.field;
        address requestedBy = reqInfo.requestedBy;

        // Ensure the field data exists for the sender
        require(bytes(users[msg.sender].feildClaims[field].field).length != 0, "Field data not found");

        // Get the field data from the sender's claims
        Claim storage claimData = users[msg.sender].feildClaims[field];

        // Create a ReceivedInfo object with the data
        ReceivedInfo memory newReceivedInfo = ReceivedInfo({
            claim: claimData,
            sender: msg.sender
        });

        // Push the received info to the requester's recinfos
        users[requestedBy].recinfos.push(newReceivedInfo);

        emit FieldInfoRecieved(requestedBy , msg.sender);
    }

   
    //function to get all the info recieved
    function getAllinfo() public view returns (string[] memory, string[] memory, address[] memory, address[] memory) {
        require(users[msg.sender].exists, "User does not exist");
        uint infoCount = users[msg.sender].recinfos.length;

        // Initialize arrays to hold the received info data
        string[] memory fields = new string[](infoCount);
        string[] memory values = new string[](infoCount);
        address[] memory issuers = new address[](infoCount);
        address[] memory senders = new address[](infoCount);

        // Populate the arrays
        for (uint i = 0; i < infoCount; i++) {
            ReceivedInfo storage info = users[msg.sender].recinfos[i];
            fields[i] = info.claim.field;
            values[i] = info.claim.value;
            issuers[i] = info.claim.issuer;
            senders[i] = info.sender;
        }
        
        return (fields, values, issuers , senders);
    }  

    function enterADocument(string memory input) public {
        users[msg.sender].documentHash.push(input);
        users[msg.sender].noOfHash++;
    }

    function renderAllDocument() public view returns (string[] memory){
        return users[msg.sender].documentHash;
    }

}