var Raffle = artifacts.require("./Raffle.sol");
module.exports = function(deployer) {
 deployer.deploy(Raffle, 0.02, 1514678400, 7, {gas: 1000000});
};