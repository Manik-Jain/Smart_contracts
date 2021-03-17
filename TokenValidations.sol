//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

/** 
 * @dev     : Validations that need to be implemented for StandardToken
 * @author  : Manik Jain
 * @title   : Validations that need to be implemented for StandardToken. 
 *            Additionally, this holds the variables being used in StandardToken
 * 
 * This contract extends the Ownable contract.
 */
contract TokenValidations is Ownable {
    
    //hold a mapping of token for each account
    mapping(address => uint) internal _balances;
    
    //hold a blacklist mapping if an account should be blacklisted
    mapping(address => bool) internal _blacklisted;
    
    //holds the timestamp when the last token was minted
    uint internal _lastMintedOn;
    
    //total tokens currently beiing minted
    uint internal _totalSupply;
    
    //maximum allowed supply of the tokens
    uint internal maxSupply = 10 ** 20;
    
    ///event emitted upon Contract being depployed
    event CONTRACT_DEPLOYED(string message);
    
    ///event emitted upon account being blacklisted
    event ACCOUNT_BLACKLISTED(string message);
    
    ///event emitted upon successful minting of tokens
    event TOKEN_MINTED(string message);
    
    ///event emitted upon successful transfer of tokens from sender's address to receipient's address
    event TOKEN_TRANSFERED(string message);
    
    ///validates that the token metadata is supplied as part of the Contract deployment
    modifier tokenMetadata(string memory name, string memory shortName) {
        require(bytes(name).length > 0, 'StandardToken [Validation Failure]: Token Name must be provided');
        require(bytes(shortName).length > 0, 'StandardToken [Validation Failure]: Token Short Name must be provided');
        _;
    }
    
    ///validates that the minimum number of tokens is atleast 10
    modifier minTokens(uint _initTokens) {
        require(_initTokens >= 10, 'StandardToken [Validation Failure]: Total supply should be minimum 10 tokens');
        _;
    }
    
    /**
     * perform the following validations before tokens are minted:
     * 
     * 1. check the last tokens were minted atleast 20 seconds before the current time
     * 2. assignee addres is a an acceptable address
     * 3. assignee is not blacklisted
     * 4. number of tokens to be minted is more than 1
     * 5. number of tokens to be minted is less than the maximum number of allowed tokens
     */
    modifier _beforeMint(address _owner, uint _amount) {
        require(block.timestamp > _lastMintedOn + 20 seconds, 'StandardToken [Validation Failure]: Minimum 20 seconds needed to mint tokens');
        require(_owner != address(0), 'StandardToken [Validation Failure]: Invalid address');
        require(_blacklisted[_owner] == false, 'StandardToken [Validation Failure]: Receipient is blacklisted');
        require(_amount >= 1, 'StandardToken [Validation Failure]: Invalid number of tokens requested to mint.');
        require(_amount < maxSupply, 'StandardToken [Validation Failure]: cannot mint tokens more than maxSupply');
        _;
    }
    
    ///make sure the sender is not blacklisted
    modifier not_blacklisted(address tokenHolder) {
        require(_blacklisted[_msgSender()] == false, 'StandardToken [Validation Failure]: Sender is blacklisted');
        require(_blacklisted[tokenHolder] == false, 'StandardToken [Validation Failure]: Receipient is blacklisted');
        _;
    }
    
    ///check whether the balance of the sender account has enough funds for transfer
    modifier at_least(uint toTransfer) {
        require(toTransfer > 0, 'StandardToken [Validation Failure]: Atleast 1 token should be transfered');
        require(toTransfer < 10 ** 60, 'StandardToken [Validation Failure]: Integer Overflow detected');
        require(_balances[_msgSender()] >= toTransfer, 'StandardToken [Validation Failure]: Insufficient tokens. Cannot proceed with transfer!');
        _;
    }
    
    ///make sure the address is not owner
    modifier notOwner(address tokenHolder) {
        require(tokenHolder != owner(), 'StandardToken [Validation Failure]: Owner cannot be blacklist');
        _;
    }
}