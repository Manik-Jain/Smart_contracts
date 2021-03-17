//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IToken.sol';
import './TokenDetails.sol';
import './TokenValidations.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

/** 
 * @dev     : Implementation of a StandardToken
 * @author  : Manik Jain
 * @title   : This is a StandardToken implementation that allows users to perform the following functions :
 * 
 * 1. Initialise the input token name, short name, and initial number of tokens to mint
 * 2. Mint a number of new tokens, and assign them to the assigned address holder
 * 3. Blacklist a token holder and/or vice-versa
 * 4. Transfer some tokens to the input token holder address
 * 5. View number of tokens being mint 
 * 6. View tokens held by the input address
 * 7. View the maximum tokens that can be minted
 * 
 * This contract extends the following 
 *  - interface : { IToken }
 * 
 *  - contracts : { Ownable,
 *                  TokenDetails, 
 *                  TokenValidations }
 * 
 */
contract StandardToken is IToken, Ownable, TokenDetails, TokenValidations {
    
    /**
     * Initialise the input token name, short name, and initial number of tokens to mint
     * 
     * Conditions : 
     * 
     * 1. Name and short name should not be empty
     * 2. Minimum 10 tokens should be minted upon contract creation
     */
    constructor(string memory _name, string memory _shortName, uint _initTokens) tokenMetadata(_name, _shortName) minTokens(_initTokens) TokenDetails(_name, _shortName) {
        _totalSupply = _initTokens;
        _balances[owner()] = _initTokens;
        emit CONTRACT_DEPLOYED('Token contract successfully deployed, and minted initial tokens');
    }
    
    /**
     * 
     * Mint a number of new tokens, and assign them to the assigned address holder
     * This function accepts the following parameters : 
     * 
     * 1. _owner  : the address of the token holder who will be assigned the minted token(s)
     * 2. _amount : the number of tokens to be minted
     * 
     * Conditions : 
     * 1. Only contract owner can invoke the mint function
     * 2. address of the assignee should be valid
     * 3. _amount must be more than 0, and less than the max tokens that can be minted
     * 
     * This function emits TOKEN_MINTED event 
     */
    function mint(address _owner, uint _amount) public onlyOwner() _beforeMint(_owner, _amount) {
        _totalSupply += _amount;
        _balances[_owner] += _amount;
        _lastMintedOn = block.timestamp;
        emit TOKEN_MINTED('StandardToken : Token minted');
    }
    
    /**
     * Blacklist a token holder account and/or vice-versa
     * 
     * Param: tokenHolder address
     *  
     * Conditions :
     * 1. Only contract owner can invoke the blacklist function
     * 2. Owner should not be blacklisted
     * 
     * This function emits ACCOUNT_BLACKLISTED event 
     */
    function blacklist(address tokenHolder) public onlyOwner() notOwner(tokenHolder) {
        _blacklisted[tokenHolder] = !_blacklisted[tokenHolder];
        emit ACCOUNT_BLACKLISTED('Account blacklisted.');
    }
    
    /**
     * Transfer some tokens to the input token holder address
     * 
     * Parameters : 
     * 1. _address: receipient address
     * 2. _amount : the number of tokens to be transfered 
     * 
     * Conditions : 
     * 1. both of the sender as well as receipient should be valid address and not blacklisted
     * 2. sender must have enough balance to transfer tokens
     * 
     * This function emits TOKEN_TRANSFERED event 
     * @return : boolean value
     */
    function transfer(address _address, uint _amount) external override payable not_blacklisted(_address) at_least(_amount) returns(bool) {
        _balances[_msgSender()] -= _amount;
        _balances[_address] += _amount;
        emit TOKEN_TRANSFERED('Tokens transfered successfully.');
        return true;
    }
    
    ///View number of tokens being mint 
    function totalSupply() external view override returns(uint) {
        return _totalSupply;
    }
    
    ///View tokens held by the input address
    function balanceOf(address _owner) external view override returns (uint) {
        return _balances[_owner];
    }
    
    ///View the maximum tokens that can be minted
    function maxTokenSupply() public view returns(uint) {
        return maxSupply;
    }
}