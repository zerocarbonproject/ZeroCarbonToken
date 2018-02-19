/*
file:   TransactionFees.sol
ver:    0.0.1
author: Philip Louw
date:   2018-02-06
email:

Used to distribute token received from suppliers to the Expenses and Rewards wallets.


Release Notes
-------------


*/


pragma solidity ^0.4.18;


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract TransactionFees is Owned {
    using SafeMath for uint;

    address constant EXPENSE_ADR      = 0x0;
    address constant REWARD_ADR       = 0x0;
    address constant TOKEN_ADR        = 0x0;

    // Commision divisor (10% of funds);
    uint public constant    COMMISION_DIV   = 10;

    // Events
    event FundsDist(uint tokensExpense, uint tokensReward);

    function TransactionFees() public {
        require(EXPENSE_ADR != 0x0);
        require(REWARD_ADR != 0x0);
        require(TOKEN_ADR != 0x0);
        require(COMMISION_DIV > 0);
        require(COMMISION_DIV < 100);
    }

    function distribute() public onlyOwner {
        distributeToken(TOKEN_ADR);
    }

    function distributeToken(address _tokenAddr) public onlyOwner {
        uint balanceT = ERC20Interface(_tokenAddr).balanceOf(this);
        require(balanceT > 0);
        uint commAmount = balanceT.div(COMMISION_DIV);
        ERC20Interface(_tokenAddr).transfer(EXPENSE_ADR, commAmount);
        ERC20Interface(_tokenAddr).transfer(REWARD_ADR, balanceT.sub(commAmount));
        FundsDist(commAmount, balanceT.sub(commAmount));
    }

    // In case someone send ETH to this address
    function cleanup() public onlyOwner {
        EXPENSE_ADR.transfer(this.balance);
    }
}
