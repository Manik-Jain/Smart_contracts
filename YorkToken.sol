// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function details() external returns(string memory, string memory);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokenDetails {
    
    string name;
    string symbol;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
}

contract  YorkERC20Token is IERC20, TokenDetails {
    // use SafeMath library
    using SafeMath for uint256;
    
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public override balanceOf;

    uint256 public override totalSupply = 1000000 ether;

    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(string memory name, string memory symbol) TokenDetails(name, symbol) {
        // Initially assign all tokens to the contract's creator.
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);  // deduct from 
        // sender's balance
        balanceOf[to] = balanceOf[to].add(value);          // 
        // add to recipient's balance
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public  override returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool success) {
        require(value <= balanceOf[from], 'Transfer Value must be less than total balance');
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
        return true;
    }
    
    function details() public view override returns(string memory, string memory) {
        return (name, symbol);
    }
}

contract DEX {
    
    event Bought(uint256 amount);
    event Sold(uint256 amount);

    IERC20 token;

    constructor(string memory name, string memory symbol) {
        token = new YorkERC20Token(name, symbol);
    }
    
    function buy() payable public {
        require(msg.value > 0, 'No Ethers provided');
        require(msg.value <= token.balanceOf(address(this)), "Not enough tokens in the reserve");
        token.transfer(msg.sender, msg.value);
        payable(address(this)).transfer(msg.value);
        emit Bought(msg.value);
    }
    
    function sell(uint256 amount) public payable {
        require(amount > 0, "You need to sell at least one tokens");
        require(amount <= token.balanceOf(msg.sender), 'Cannot sell tokens over the owner allowance');
        require(amount < token.balanceOf(address(this)), 'Cannot sell tokens held by contract');
        token.approve(address(this), amount);
        token.transferFrom(msg.sender, address(this), amount);
        payable(address(msg.sender)).transfer(amount);
        emit Sold(amount);
    }
    
    function tokensOf(address _owner) public view returns(uint) {
        require(_owner != address(0), 'Invalid address');
        return token.balanceOf(_owner);
    }
    
    function details() public returns(string memory, string memory) {
        return token.details();
    }
    
    receive() payable external {
        
    }
}