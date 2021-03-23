const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const BTYmain = artifacts.require("BTYmain.sol");
const QuizeTokenSale = artifacts.require("QuizeTokenSale");


module.exports = async (deployer, network) => {
    if (network === 'goerli' && process.env.NODE_ENV === "update") {
        await deployContract(deployer)
    } else if (network === "mainnet" && process.env.NODE_ENV === "update") {
        await deployContract(deployer)
    }
};

async function deployContract(deployer) {
    const exisBTY = await QuizeTokenSale.deployed();
    const instance = await upgradeProxy(exisBTY.address, QuizeTokenSale, { deployer });
    console.log("Upgraded", instance.address);

}