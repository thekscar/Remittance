var Splitter = artifacts.require("./Splitter.sol");

module.exports = function(deployer) {
  deployer.deploy(Splitter);
  //What exactly does link do? 
  // deployer.link(ConvertLib, MetaCoin);
};
