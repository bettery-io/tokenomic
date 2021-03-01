const BETTokenContract = artifacts.require("BET.sol")
const BTYTokenContract = artifacts.require("BTY.sol");
const PrivateEventContract = artifacts.require("PrivateEvents.sol");
const PublicEventContract = artifacts.require("PublicEvents.sol");
const GrowthFactorEvents = artifacts.require("GrowthFactorEvents.sol");
const ProEventsContract = artifacts.require("ProEvents.sol")
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

    await deployer.deploy(PrivateEventContract);

    await deployer.deploy(PublicEventContract, BETTokenContract.address, BTYTokenContract.address);

    await deployer.deploy(ProEventsContract, BETTokenContract.address, BTYTokenContract.address);

    await deployer.deploy(GrowthFactorEvents);

  }else{
    return;
  }
}