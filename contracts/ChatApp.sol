// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0

contract ChatApp {
    
    //USER STRUCT
    struct user{
        string name;
        friend[] = friendList;
    }

    struct friend{
        address pubkey;
        string name;
    }

    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUsersStruct{
        string name;
        address account_address;
    }

    AllUsersStruct[] getAllUsers;

    mapping(address => user) UserList;
    mapping(bytes32 => message[]) allMessages;

    //CHECK USER EXIST
    function checkUserExists(address pubkey) public view returns(bool){
        return bytes(userList[pubkey].name).length > 0;
    }

    //CREATE ACCOUNT
    function createAccount(string calldata name) external{
        require(checkUserExists(msg.sender) == false, "User Already exists");
        require(bytes(name).length > 0,"Username cannot be empty");

        userList[msg.sender].name = name;

        getAllUsers.push(AllUsersStruct(name, msg.sender));
    }

    //GET USERNAME
    function getUserName(address pubkey) external view returns (string memory) {
        require(checkUserExists(pubkey), "User is not registered");
        return userList[pubkey].name;
    }

    //ADD FRIEND
    function addFriend(address friend_key, string calldata name) external{
        require(checkUserExists(msg.sender), "Create an Account first");
        require(checkUserExists(freind_key), "User is not registered!");
        require(msg.sender != friend_key,"Users cannot be friends with themselves");
        require(checkAlreadyFriend(msg.sender, friend_key) == false, "These users are already friends");

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key,  msg.sender, userList[msg.sender].name);
    }

    //CHECK ALREADY FRIENDS
    function checkAlreadyFriend(address pubkey1, address pubkey2) internal view returns (bool){
        if (userList[pubkey1].friendList.length > userList[pubkey2].friendList.length){
            address temp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = temp;
        }

        for(uint256 i = 0; i < userList[pubkey1].friendList.length; i++){
            if (userList[pubkey1].friendList[i].pubkey == pubkey2){
                return true;
            }
        }
        return false;
    }

    function _addFriend(address me, address friend_key, string memory name) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    //GET FRIENDS LIST
    function getMyFriendList() external view returns (friend[] memory){
        return userList[msg.sender].friendList;
    }

    //GET CHAT CODE
    function _getChatCode(address pubkey1, address pubkey2) internal view returns (bytes32){
        if (pubkey1 < pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        }
        else{
            return keccak256(abi.encodePacked(pubkey2, pubkey1));
        }
    }

    //SEND MESSAGE
    function sendMessage(address friend_key, string calldata _msg) external{
        require(checkUserExists(msg.sender), "Create account first");
        require(checkUserExists(friend_key), "User not registered");
        require(checkAlreadyFriend(msg.sender, friend_key), "Not friends");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    //READ MESSAGE 
    function readMessage(addess friend_key) external view returns (message[] memory){
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    //GET ALL USERS
    function getAppUsers() public view returns(AllUsersStruct[] memory){
        return getAllUsers;
    }
}