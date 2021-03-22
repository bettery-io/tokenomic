const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const BTYmain = artifacts.require("BTYmain.sol");
const QuizeTokenSale = artifacts.require("QuizeTokenSale.sol");
const Web3 = require("web3");
const config = require("../config/tokensConfig");
const networkConfig = require("../config/networks");


module.exports = async (deployer, network) => {
  if (network === 'goerli') {
    let usdtAddress = '0xFCf9F99D135D8a78ab60CC59CcCF3108E813bA35'
    await deployContract(deployer, usdtAddress, networkConfig.goerliId)
  } else if(network === "mainnet") {
    let usdtAddress = '0xdac17f958d2ee523a2206206994597c13d831ec7'
    await deployContract(deployer, usdtAddress, networkConfig.etherMainId)
  }
};

async function deployContract(deployer, USDTAddress, chain_id){
  let web3 = new Web3();
  let name = config.btyName;
  let symbol = config.btySymbol;
  let decimals = config.decimals;
  let initSupCoins = config.initSupCoinsEtherNet;
  let initialSupplyCoins = web3.utils.toWei(String(initSupCoins), "ether");
  await deployProxy(BTYmain, [name, symbol, decimals, initialSupplyCoins, chain_id], { deployer, initializer: '__BTYmainInit' });

  // token price 
  let tokenPrice = web3.utils.toWei("0.01", "mwei");
  return await deployProxy(QuizeTokenSale, [BTYmain.address, tokenPrice, USDTAddress], { deployer, initializer: '__QuizeTokenSaleInit' });
}