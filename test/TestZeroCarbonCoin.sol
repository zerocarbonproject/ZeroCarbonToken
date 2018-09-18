pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ZeroCarbonCoin.sol";

contract TestZeroCarbonCoin {


    constructor () public {
        // constructor
    }

    function testInitialBalanceUsingDeployedContract() public {
        ZeroCarbonCoin meta = ZeroCarbonCoin(DeployedAddresses.ZeroCarbonCoin());

        uint expected = 240000000000000000000000000;

        Assert.equal(meta.balanceOf(tx.origin), expected, "Owner should have 240000000000000000000000000 ZeroCaronCoin initially");
    }

}
