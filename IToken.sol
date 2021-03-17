//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * interface declaration for a standard Token
 * that declares three functions which must be 
 * defined in the implementing contracts
 * 
 * @author : Manik Jain
 */
interface IToken {
    
    ///Transfer some tokens to the input token holder address, and returns a boolean value
    function transfer(address _address, uint _amount) external payable returns (bool);
    
    ///View number of tokens being mint 
    function totalSupply() external view returns (uint);
    
    ///View tokens held by the input address
    function balanceOf(address _owner) external view returns (uint);
}