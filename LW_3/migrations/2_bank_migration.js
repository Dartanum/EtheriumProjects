const Bank = artifacts.require("Bank");
const Gachi = artifacts.require("Gachi");

module.exports = async function (deployer) {
  await deployer.deploy(Gachi);
  const token = await Gachi.deployed();
  await deployer.deploy(Bank, token.address, 200);
};
