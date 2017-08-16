var Remittance = artifacts.require("./Remittance.sol");

contact('Remittance', function(accounts){
  var contract ; //Instance of contract deployed

  var owner = accounts[0]; //Me
  var alice = accounts[1]; //Alice
  var carol = accounts[2]; //Carol
  var bob   = accounts[3]; //Bob 

  passOne = 'passwordOne';
  passTwo = 'passwordTwo';

  //Step to take before each test runs, deploy contract each
  //time to start at the "same base case"
beforeEach(function(){
  return Remittance.new({from:owner})
  .then(function(instance){
    contract = instance; 
  });
});

//First test, contract should be owned by me. 
it("Should be owned by me.", function(){
  .then(function(_owner){
    assert.strictEqual(_owner, owner, "Contract not owned by me.")
  });
});

//Second test, Alice should be able to send ether

//Third test, Nobody else should be able to send ether to the contract

//Fourth test Alice should be able to send passwords (aliceSendPas)

//Fifth test, nobody else should be able to send password (aliceSendPas)

//Sixth test, Carol should be able to send password (carolEx)

//Seventh test, nobody else should be able to try Carol's password (carolEx)

//Eighth test, Carol should be able to send back Ether to Bob

//And more...

})
