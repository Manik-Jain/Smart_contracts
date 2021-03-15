//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

//ERC-20 inspired Base contract holding basic token TokenDetails
//1. Name
//2. shortName
contract TokenDetails {
    
    string name;
    string shortName;
    
    //constructor to initiate the token basic details
    constructor(string memory _name, string memory _shortName) {
        name = _name;
        shortName = _shortName;
    }
    
    //returns the token Name
    function tokenName() public view returns (string memory) {
        return name;
    }
    
    //retuns token short name
    function tokenShortName() public view returns (string memory) {
        return shortName;
    }
    
    //return tuple of token name and shortname
    function tokenDetails() public view returns (string memory, string memory) {
        return (name, shortName);
    }
}

//Contract that extends two tokens to maintain token information
//1. TokenDetails : this holds the basic information of tokens
//2, Ownable : An OpenZeppelin contract to maintain contract ownership
contract Token is TokenDetails, Ownable {
    
    //this state variable is not needed anymore, since OpenZeppelin is handling this for us.
    //address owner;
    
    //holds the balance of all accounts
    mapping(address => uint) balances;
    
    //holds whether the account is blacklisted or non-blacklisted
    mapping(address => bool) blacklisted;
    
    //event emitted upon successful transfer of tokens from sender's address to receipient's address
    event TOKEN_TRANSFERED(string message);
    
    //event emitted upon account being blacklisted
    event ACCOUNT_BLACKLISTED(string message);
    
    //initializes the owner with the contract creator’s address using OpenZeppelin 
    //and some non-zero token balance to the owner
    constructor(string memory name, string memory shortName, uint initBalance) TokenDetails(name, shortName) {
        balances[owner()] = initBalance;
    }
    
    //make sure the sender is not blacklisted
    modifier not_blacklisted(address tokenHolder) {
        require(blacklisted[_msgSender()] == false, 'Sender is blacklisted');
        require(blacklisted[tokenHolder] == false, 'receipient is blacklisted');
        _;
    }
    
    //check whether the balance of the sender account has enough funds for transfer
    modifier at_least(uint toTransfer) {
        require(balances[_msgSender()] >= toTransfer, 'Insufficient tokens. Cannot proceed with transfer!');
        _;
    }
    
    //change a non-blacklisted account to a blacklisted account
    //only Owners can invooke this function, relies on OpenZeppelin for this validation
    function blacklist(address tokenHolder) public onlyOwner() {
        blacklisted[tokenHolder] = true;
        emit ACCOUNT_BLACKLISTED('Account blacklisted.');
    }
    
    //transfers the tokens from the sender's account to the recipient’s account, after the following validation checks
    //1. the message sender as well as the recipient is not blacklisted
    //2. sender has enough token balance to proceed with the transfer
    // Upon successful transfer, an event ins triggered to signify the token transfer
    function transfer(address tokenHolder, uint toTransfer) public not_blacklisted(tokenHolder) at_least(toTransfer) {
        balances[_msgSender()] -= toTransfer;
        balances[tokenHolder] += toTransfer;
        emit TOKEN_TRANSFERED('Tokens transfered successfully.');
    }
    
    //returns the tokens held by the provided address, along with the blakckist status
    function tokenBalance(address tokenHolder) public view returns (uint, bool) {
        return (balances[tokenHolder], blacklisted[tokenHolder]);
    }
}