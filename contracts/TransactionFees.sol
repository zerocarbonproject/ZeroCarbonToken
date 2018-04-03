pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts//math/SafeMath.sol";


/**
 * @title Transaction Fees
 * 
 * Used to split the fees received from suppliers between reward and operational cost wallet.
 *
 * (c) Philip Louw / Zero Carbon Project 2018. The MIT Licence.
 */
contract TransactionFees is Claimable {
  using SafeMath for uint256;

  address constant REWARD_ADR       = 0x0;
  address constant OPERATIONAL_ADR  = 0x0;

  // No more than 40 000 token per week to operational cost
  uint256 constant MAX_TOKENS_WEEK = 400000 * (10 ** uint256(18));
  // Minimum opertational cost per week
  uint256 constant MIN_TOKENS_WEEK = 12000 * (10 ** uint256(18));

  uint256 public lastDistWeekIdx;

  // Commision divisor (10% of funds);
  uint256 public constant    COMMISION_DIV   = 10;

  // Events
  event FundsDist(uint tokensExpense, uint tokensReward);

  function TransactionFees() public {
    require(REWARD_ADR != 0x0);
    require(OPERATIONAL_ADR != 0x0);
    require(COMMISION_DIV > 0);
    require(COMMISION_DIV < 100);
    lastDistWeekIdx = weekIdx();
  }

  function distributeToken(address _tokenAddr) public onlyOwner {
    // Distribution can only happen once a week
    require(weekIdx() > lastDistWeekIdx);

    uint256 balanceT = ERC20Basic(_tokenAddr).balanceOf(this);
    require(balanceT > 0);
    uint256 commAmount = balanceT.div(COMMISION_DIV);
    ERC20Basic(_tokenAddr).transfer(OPERATIONAL_ADR, commAmount);
    ERC20Basic(_tokenAddr).transfer(REWARD_ADR, balanceT.sub(commAmount));
    FundsDist(commAmount, balanceT.sub(commAmount));
  }

  /**
  * @dev Private function to determine week index
  * @return uint256 of week index
  */
  function weekIdx() private view returns (uint256) {
      return now / 1 weeks;
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