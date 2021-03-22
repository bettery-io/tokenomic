const BETTokenContract = artifacts.require("BET.sol")
const BTYTokenContract = artifacts.require("BTY.sol");
const PrivateEventContract = artifacts.require("PrivateEvents.sol");
const PublicEventContract = artifacts.require("PublicEvents.sol");
const MiddlePaymentContract = artifacts.require("MiddlePayment.sol");
const PlayerPaymentContract = artifacts.require("PlayerPayment.sol");
const GrowthFactorEvents = artifacts.require("GrowthFactorEvents.sol");
const ProEventsContract = artifacts.require("ProEvents.sol")
const maticNetwork = require("../config/matic.json");
const config = require("../config/tokensConfig");
const networkConfig = require("../config/networks");

module.exports = async function (deployer, network) {
  if (network === 'matic' || network === "development") {
    let chain_id;
    let ChildChainManagerProxy;
    if(network === 'matic' || network === "development"){
      chain_id = networkConfig.maticMumbaiId;
      ChildChainManagerProxy = maticNetwork.child.ChildChainManagerProxy
    }else if(network === "mainMatic"){
      chain_id = networkConfig.maticMainId;
      ChildChainManagerProxy = "" // TODO add CHILDCHAIN
    }
    let decimals = config.decimals;
    let nameBET = config.betName;
    let symbolBET = config.betSymbol
    await deployer.deploy(BETTokenContract, nameBET, symbolBET, decimals, chain_id);

    let nameBTY = config.btyName;
    let symbolBTY = config.btySymbol;
    await deployer.deploy(BTYTokenContract, nameBTY, symbolBTY, decimals, BETTokenContract.address, ChildChainManagerProxy, chain_id);

    await deployer.deploy(PrivateEventContract);

    await deployer.deploy(PublicEventContract, BETTokenContract.address, BTYTokenContract.address);

    await deployer.deploy(MiddlePaymentContract, PublicEventContract.address);

    await deployer.deploy(PlayerPaymentContract, PublicEventContract.address, MiddlePaymentContract.address);

    await deployer.deploy(ProEventsContract, BETTokenContract.address, BTYTokenContract.address);

    await deployer.deploy(GrowthFactorEvents);

  }else{
    return;
  }
}