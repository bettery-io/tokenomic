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

module.exports = async function (deployer, network) {
  if (network === 'matic' || network === "development") {
    // TODO switch to the production network
    let decimals = config.decimals;
    let nameBET = config.betName;
    let symbolBET = config.betSymbol
    let chain_id = 80001 // TODO switch to Matic main netowrk
    await deployer.deploy(BETTokenContract, nameBET, symbolBET, decimals, chain_id);

    let nameBTY = config.btyName;
    let symbolBTY = config.btySymbol;
    let ChildChainManagerProxy = maticNetwork.child.ChildChainManagerProxy
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