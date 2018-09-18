const ZeroCarbonCoin = artifacts.require("./ZeroCarbonCoin.sol");

const BigNumber = web3.BigNumber;

contract('ZeroCarbonCoin', function(accounts) {

  describe('Contract Creation Tests', function() {

    beforeEach(async function () {
      this.token = await ZeroCarbonCoin.new();
    });

    it('should put 240000000000000000000000000 Energis Token in the first account', async function() {
      const balance = await this.token.balanceOf.call(accounts[0]);
      assert.isTrue(new BigNumber('240000000000000000000000000').comparedTo(balance) == 0, "240000000000000000000000000 wasn't in the first account");
    });
  });

  describe('ERC20 Functions test', function() {
    it('Test transfering money', function() {
      return ZeroCarbonCoin.new().then(async function(instance) {
        var acc0Bal = await instance.balanceOf.call(accounts[1]);
        assert.isTrue(new BigNumber('0').comparedTo(acc0Bal) == 0, 'Balance should be zero');

        await instance.transfer(accounts[1], 1000);
        acc0Bal = await instance.balanceOf.call(accounts[1]);
        assert.isTrue(new BigNumber('0').comparedTo(acc0Bal) != 0, 'Balance should be 1000');
        assert.isTrue(new BigNumber('1000').comparedTo(acc0Bal) == 0, 'Balance should be 1000');

        await instance.transfer(accounts[0], 1000, { from: accounts[1] });
        acc0Bal = await instance.balanceOf.call(accounts[0]);
        assert.isTrue(new BigNumber('240000000000000000000000000').comparedTo(acc0Bal) == 0, 'Balance should be 240 mil');
        acc0Bal = await instance.balanceOf.call(accounts[1]);
        assert.isTrue(new BigNumber('0').comparedTo(acc0Bal) == 0, 'Balance should be 0');
      });
    });
  });

  it('Payment should not be accepted', function() {
    return ZeroCarbonCoin.new().then(function(instance) {
     return instance.send(1000000);
    }).then(function(result) {
      assert.isTrue(false,'Payment should not be accepted');
    }, function(error) {
      assert.isTrue(true,'Payment was rejected');
    });
  });

  

  describe('Ownership tests', function() {

    it('Contract should have a owner', function() {
      return ZeroCarbonCoin.new().then(function(instance) {
        return instance.owner();
      }).then(function(owner) {
        assert.isTrue(owner !== 0, 'Owner is set');
      });
    });

    it('Contract creator should be owner', function() {
      return ZeroCarbonCoin.new().then(function(instance) {
        return instance.owner();
      }).then(function(owner) {
        assert.isTrue(owner == accounts[0], 'Owner is set to creator');
      });
    });

    it('Initial Step in Ownership', function() {
      return ZeroCarbonCoin.new().then(async function(instance) {
        await instance.transferOwnership(accounts[1]);
        var currOwner = await instance.owner();
        var currPendingOwner = await instance.pendingOwner();
        assert.isTrue(currOwner == accounts[0], 'Owner is set to creator');
        assert.isTrue(currPendingOwner == accounts[1], 'new owner is set to transfered owner');
      });
    });

    it('Claim OwnerShip', function() {
      return ZeroCarbonCoin.new().then(async function(instance) {
        await instance.transferOwnership(accounts[1]);
        await instance.claimOwnership({ from: accounts[1]});
        var currOwner = await instance.owner();
        var currPendingOwner = await instance.pendingOwner();
        assert.isTrue(currOwner == accounts[1], 'New owner should be set');
      });
    });
  });

  describe('Token Burning', function() {

    beforeEach(async function () {
      this.token = await ZeroCarbonCoin.new();
    });

    it('burns the account tokens', async function() {
      const amountBurn = new BigNumber('100');
      const tokensAmount = await this.token.balanceOf.call(accounts[0], {from: accounts[0]});
      await this.token.burn(amountBurn, {from: accounts[0]});

      const newBalance2 = await this.token.balanceOf.call(accounts[0], {from: accounts[0]});
      const newBalance = await this.token.balanceOf.call(accounts[0], {from: accounts[0]});
      assert.isTrue(tokensAmount.minus(amountBurn).eq(newBalance));
    });

    it('token burns updates the total supply', async function() {
      const amountBurn = new BigNumber(100);
      const totalSupply = await this.token.totalSupply.call();
      await this.token.burn(amountBurn);

      const totalSupplyAfter = await this.token.totalSupply.call();
      assert.isTrue(totalSupplyAfter.add(amountBurn).eq(totalSupply) );
    });
  });

  describe('transfer Any ERC20 Token', function() {
    beforeEach(async function () {
      this.tokenA = await ZeroCarbonCoin.new({from: accounts[0]});
      this.tokenB = await ZeroCarbonCoin.new({from: accounts[1]});
    });

    it('Claim acidental send tokens', async function() {
      const amountTokensB = new BigNumber('100');

      // Send 100 TokenB to contract TokenA
      await this.tokenB.transfer(this.tokenA.address, amountTokensB, {from: accounts[1]});

      // Validate 100 TokenB in contract TokenA
      const tokenAtokenBbalance = await this.tokenB.balanceOf.call(this.tokenA.address);
      assert.isTrue(amountTokensB.eq(tokenAtokenBbalance), 'Token A should now have a Token B balance of 100');

      // Validate acc01 has 0 TokenB
      const acc0tokenBbalance = await this.tokenB.balanceOf.call(accounts[0]);
      assert.isTrue(new BigNumber('0').eq(acc0tokenBbalance), 'Initial balance should be 0');

      await this.tokenA.transferAnyERC20Token(this.tokenB.address, amountTokensB, {from: accounts[0]});

      const acc0tokenBbalanceAfter = await this.tokenB.balanceOf.call(accounts[0]);
      assert.isTrue(amountTokensB.eq(acc0tokenBbalanceAfter), 'TokenB balance should be 100');


    });
  });
});
