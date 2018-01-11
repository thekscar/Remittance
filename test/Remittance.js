const Remittance = artifacts.require("./Remittance.sol");

const timeTravel = function (time) {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [time], // 86400 is num seconds in day
        id: new Date().getTime()
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

const mineBlock = function () {
    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_mine"
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
  }

contract('Remittance', function(accounts){
  let contract ; //Instance of contract deployed
  let owner = accounts[0]; //Me or deployer
  let alice = accounts[1]; //Alice
  let carol = accounts[2]; //Carol
  
  let pass1 = 'Here is a random string!';
  let pass2 = 'Here is another random string!';

  let pass1Hashed = web3.sha3(pass1);
  let pass2Hashed = web3.sha3(pass2);
    
   /* Steps to take before each test run, deploy contract each time to start
  at same base case. */
  beforeEach(async function(){
    contract = await Remittance.new(); 
  });
  
  //Contract should be owned by deployer
  describe("Ownership", async function() {
    it("Should be owned by Deployer.", async function(){
      let remittanceowner = await contract.owner({from:owner});
      assert.strictEqual(remittanceowner, owner, "Contract not owned by Deployer.");
    })
  })

  //Contract should be able to receive Ether and record information for an exchanger
  describe("Sending Ether to contract", async function() {
    it("Should allow individuals to send ether with secrets hashed an a limit", async function() {
      let bothHashed = await contract.hashPlease(pass1Hashed, pass2Hashed);
      let result = await contract.sendEth(bothHashed, 1000, carol, {from:alice, value: 100});
      let carolsbal = await contract.balances(carol); 
      let tx = result.logs[0];
      assert.equal(carolsbal.toString(10), 95, "Carol's balance correctly allotted.");
      assert.strictEqual(tx.args.sender, alice, "Sender recorded correctly.");
      assert.strictEqual(tx.args.exchanger, carol, "Exchanger recorded correctly.");
      assert.equal(tx.args.limit, 1000, "Limit recorded correctly.");
      assert.strictEqual(tx.args.hashOfBoth, bothHashed, "Password recorded correctly.")
    })
  })

  //Contract should allow an exchanger to pull their allotted Ether 
  describe("Exchanger withdrawing Ether", async function() {
    it("Should allow exchanger to withdraw allotted funds within time limit", async function() {
      let bothHashed = await contract.hashPlease(pass1Hashed, pass2Hashed);
      let result = await contract.sendEth(bothHashed, 100000, carol, {from:alice, value: 100});
      let nextresult = await contract.exchangerWithdrawl(pass1Hashed, pass2Hashed, {from: carol, gas: 3000000});
      let carolsbal = await contract.balances(carol);
      let tx = nextresult.logs[0];
      assert.equal(carolsbal.toString(10), 0, "Carol's balance incorrect, not withdrawn correctly.");
      assert.strictEqual(tx.args.sender, alice, "Sender is incorrect.");
      assert.strictEqual(tx.args.exchanger, carol, "Exchanger is incorrect");
      assert.equal(tx.args.amount.toString(10), 95, "Carol withdrew the incorrect amount.")
    })
  })

  //Contract should record when the time limit is done. 
  describe("Time limit for withdraw", async function() {
    it("Should record when the time limit has passed and let Alice withdraw", async function() {
      let bothHashed = await contract.hashPlease(pass1Hashed, pass2Hashed);
      let result = await contract.sendEth(bothHashed, 100000, carol, {from: alice, value: 100});
      await timeTravel(200000); //Pass the time limit
      await mineBlock(); //Getting around a current bug
      let nextresult = await contract.isStillGoing(bothHashed);
      assert.isFalse(nextresult, "There is an error, the contract has not ended.")
      let anotherresult = await contract.timeLimitUp(bothHashed, {from:alice});
      let tx = anotherresult.logs[0];
      assert.strictEqual(tx.args.sender, alice, "Sender is not correct.");
      assert.equal(tx.args.amount, 95, "Amount refunded is not correct.")
    })
  })

})
