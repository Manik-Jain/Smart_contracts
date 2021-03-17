//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** 
 * @dev     : Holds the token metadata for a token
 * @author  : Manik Jain
 */
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