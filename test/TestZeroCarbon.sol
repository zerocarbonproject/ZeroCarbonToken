pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ZeroCarbon.sol";

contract TestZeroCarbon {


    constructor () public {
        // constructor
    }

    function testInitialBalanceUsingDeployedContract() public {
        ZeroCarbon meta = ZeroCarbon(DeployedAddresses.ZeroCarbon());

        uint expected = 240000000000000000000000000;

        Assert.equal(meta.balanceOf(tx.origin), expected, "Owner should have 240000000000000000000000000 ZeroCaronCoin initially");
    }

}
