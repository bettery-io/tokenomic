const BETTokenContract = artifacts.require("BET.sol")
const BTYTokenContract = artifacts.require("BTY.sol");
const maticNetwork = require("../config/matic.json");
const config = require("../config/tokensConfig");

module.exports = async function (deployer, network) {

  if (network === 'matic' || network === "development") {
    let decimals = config.decimals;
    let nameBET = config.betName;
    let symbolBET = config.betSymbol
    await deployer.deploy(BETTokenContract, nameBET, symbolBET, decimals);

    let nameBTY = config.btyName;
    let symbolBTY = config.btySymbol;
    // TODO switch to the production network
    let ChildChainManagerProxy = maticNetwork.child.ChildChainManagerProxy
    await deployer.deploy(BTYTokenContract, nameBTY, symbolBTY, decimals, BETTokenContract.address, ChildChainManagerProxy);


  }else{
    return;
  }
}