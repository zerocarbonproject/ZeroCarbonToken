const BigNumber = web3.BigNumber;
const EnergisToken = artifacts.require("./EnergisToken.sol");

contract('EnergisToken', function(accounts) {

  describe('Contract Creation Tests', function() {
    it('should put 240000000000000000000000000 Energis Token in the first account', function() {
      return EnergisToken.deployed().then(function(instance) {
        return instance.balanceOf.call(accounts[0]);
      }).then(function(balance) {
        assert.equal(balance.valueOf(), 240000000000000000000000000, "240000000000000000000000000 wasn't in the first account");
      });
    });
  });

  describe('ERC20 Functions test', function() {
    it('Test transfering money', function() {
      return EnergisToken.deployed().then(async function(instance) {
        var acc0Bal = await instance.balanceOf.call(accounts[1]);
        assert.isTrue(acc0Bal == 0, 'Balance should be zero');

        await instance.transfer(accounts[1], 1000);
        acc0Bal = await instance.balanceOf.call(accounts[1]);
        assert.isTrue(acc0Bal == 1000, 'Balance should be 1000');

        await instance.transfer(accounts[0], 1000, { from: accounts[1] });
        acc0Bal = await instance.balanceOf.call(accounts[0]);
        assert.isTrue(acc0Bal == 240000000000000000000000000, 'Balance should be 240 mil');
        acc0Bal = await instance.balanceOf.call(accounts[1]);
        assert.isTrue(acc0Bal == 0, 'Balance should be 0');
      });
    });
  });

  it('Payment should not be accepted', function() {
    return EnergisToken.deployed().then(function(instance) {
     return instance.send(1000000);
    }).then(function(result) {
      assert.isTrue(false,'Payment should not be accepted');
    }, function(error) {
      assert.isTrue(true,'Payment was rejected');
    });
  });

  

  describe('Ownership tests', function() {

    it('Contract should have a owner', function() {
      return EnergisToken.deployed().then(function(instance) {
        return instance.owner();
      }).then(function(owner) {
        assert.isTrue(owner !== 0, 'Owner is set');
      });
    });

    it('Contract creator should be owner', function() {
      return EnergisToken.deployed().then(function(instance) {
        return instance.owner();
      }).then(function(owner) {
        assert.isTrue(owner == accounts[0], 'Owner is set to creator');
      });
    });

    it('Initial Step in Ownership', function() {
      return EnergisToken.deployed().then(async function(instance) {
        await instance.transferOwnership(accounts[1]);
        var currOwner = await instance.owner();
        var currPendingOwner = await instance.pendingOwner();
        assert.isTrue(currOwner == accounts[0], 'Owner is set to creator');
        assert.isTrue(currPendingOwner == accounts[1], 'new owner is set to transfered owner');
      });
    });

    it('Claim OwnerShip', function() {
      return EnergisToken.deployed().then(async function(instance) {
        await instance.claimOwnership({ from: accounts[1]});
        var currOwner = await instance.owner();
        var currPendingOwner = await instance.pendingOwner();
        assert.isTrue(currOwner == accounts[1], 'New owner should be set');
      });
    });
  });

  describe('Token Burning', function() {

    beforeEach(async function () {
      this.token = await EnergisToken.new();
    });

    it('burns the account tokens', async function() {
      const amountBurn = 100;
      let tokensAmount = await this.token.balanceOf(accounts[0]);
      await this.token.burn(amountBurn);

      const newBalance = await this.token.balanceOf(accounts[0]);
      assert.equal(newBalance, tokensAmount - amountBurn);
    });

    it('token burns updates the total supply', async function() {
      const amountBurn = 100;
      let totalSupply = await this.token.totalSupply();
      await this.token.burn(amountBurn);

      const totalSupplyAfter = await this.token.totalSupply();
      assert.isTrue(new BigNumber(totalSupplyAfter).add(amountBurn).eq(new BigNumber(totalSupply)) );
    });
  });
});
