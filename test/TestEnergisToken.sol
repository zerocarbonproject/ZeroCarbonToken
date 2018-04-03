pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EnergisToken.sol";

contract TestEnergisToken {


    function TestEnergisToken() public {
        // constructor
    }

    function testInitialBalanceUsingDeployedContract() public {
        EnergisToken meta = EnergisToken(DeployedAddresses.EnergisToken());

        uint expected = 240000000000000000000000000;

        Assert.equal(meta.balanceOf(tx.origin), expected, "Owner should have 240000000000000000000000000 Energis Tokens initially");
    }

}
