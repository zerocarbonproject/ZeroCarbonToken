pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Claimable.sol";

/**
 * @title EnergisToken
 * 
 * Symbol      : ERG
 * Name        : Energis Token
 * Total supply: 240,000,000.000000000000000000
 * Decimals    : 18
 *
 * (c) Philip Louw / Zero Carbon Project 2018. The MIT Licence.
 */
contract EnergisToken is StandardToken, Claimable {
  using SafeMath for uint256;

  string public constant name = "Energis Token"; // solium-disable-line uppercase
  string public constant symbol = "NRG"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 240000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function EnergisToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  /**
  * @dev Reject all ETH sent to token contract
  */
  function () public payable {
    // Revert will return unused gass throw will not
    revert();
  }

  /**
   * @dev Owner can transfer out any accidentally sent ERC20 tokens
   */
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Basic(tokenAddress).transfer(owner, tokens);
  }  
}
