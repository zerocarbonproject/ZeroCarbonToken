const Distributor = artifacts.require("./Distributor.sol");
const EnergisToken = artifacts.require("./EnergisToken.sol");

const BigNumber = web3.BigNumber;

contract('Distributor', function(accounts) {

  beforeEach(async function () {
    this.dist = await Distributor.new();
    this.token = await EnergisToken.new();
  });

  describe('Test Ownership', function(done) {
    it('Contract should have a owner',async function() {
    });

    it('Contract creator should be owner',async function() {
      const owner = await this.dist.owner();
      assert.isTrue(owner == accounts[0], 'Owner is set to creator');
    });

    it('Initial Step in Ownership',async function() {
      await this.dist.transferOwnership(accounts[1]);
      var currOwner = await this.dist.owner();
      var currPendingOwner = await this.dist.pendingOwner();
      assert.isTrue(currOwner == accounts[0], 'Owner is set to creator');
      assert.isTrue(currPendingOwner == accounts[1], 'new owner is set to transfered owner');
    });

    it('Claim OwnerShip',async function() {
      await this.dist.transferOwnership(accounts[1]);
      await this.dist.claimOwnership({ from: accounts[1]});
      var currOwner = await this.dist.owner();
      var currPendingOwner = await this.dist.pendingOwner();
      assert.isTrue(currOwner == accounts[1], 'New owner should be set');
    });
  });

  describe('Test multiSend', function(done) {
    it('Set allowance',async function() {
      await this.token.transfer(this.dist.address, 200, {from : accounts[0]});

      let distTokenBalance = await this.token.balanceOf.call(this.dist.address);
      assert.isTrue(distTokenBalance.eq(new BigNumber('200')), 'Dist contract should have balance of 200');

      await this.dist.multisend(this.token.address, [accounts[2], accounts[3]], [100, 100], {from : accounts[0]} );

      distTokenBalance = await this.token.balanceOf.call(this.dist.address);
      assert.isTrue(distTokenBalance.eq(new BigNumber('0')), 'Dist contract should have balance of 0');

      const acc2Balance = await this.token.balanceOf.call(accounts[2]);
      assert.isTrue(acc2Balance.eq(new BigNumber('100')), 'Acc02 should have balance of 100');

      const acc3Balance = await this.token.balanceOf.call(accounts[3]);
      assert.isTrue(acc3Balance.eq(new BigNumber('100')), 'Acc03 should have balance of 100');
    });
  });
});
