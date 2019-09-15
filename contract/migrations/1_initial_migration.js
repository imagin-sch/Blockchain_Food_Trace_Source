const Migrations = artifacts.require("Migrations");
const Trace_Source = artifacts.require("Trace_Source");
module.exports = function(deployer) {
	deployer.deploy(Migrations);
	deployer.deploy(Trace_Source);
};
