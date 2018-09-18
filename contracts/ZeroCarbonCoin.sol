pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/ownership/Claimable.sol";

/**
 * @title ZeroCarbonCoin
 * 
 * Symbol      : ZCC
 * Name        : Zero Carbon Coin
 * Total supply: 240,000,000.000000000000000000
 * Decimals    : 18
 *
 * (c) Philip Louw / Zero Carbon Project 2018. The MIT Licence.
 */
contract ZeroCarbonCoin is StandardToken, Claimable, BurnableToken {
    using SafeMath for uint256;

    string public constant name = "ZeroCarbonCoin"; // solium-disable-line uppercase
    string public constant symbol = "ZCC"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    uint256 public constant INITIAL_SUPPLY = 240000000 * (10 ** uint256(decimals));

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor () public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    /**
    * @dev Owner can transfer out any accidentally sent ERC20 tokens
    */
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Basic(tokenAddress).transfer(owner, tokens);
    }  
}
