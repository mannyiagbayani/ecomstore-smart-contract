const EcomStore = artifacts.require("./EcomStore.sol")
module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(EcomStore);
};
