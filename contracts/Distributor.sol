pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Claimable.sol";

/*
file:   Distributor.sol
ver:    0.0.1
author: Philip Louw
date:   2018-02-06
email:

Used to distribute token from the rewards pool to the customers.


Release Notes
-------------


*/

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

contract Distributor is Claimable {

    function multisend(address _tokenAddr, address[] dests, uint256[] values) public onlyOwner returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            ERC20Interface(_tokenAddr).transfer(dests[i], values[i]);
            i += 1;
        }
        return(i);
    }
}
