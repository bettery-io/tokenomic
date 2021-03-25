const { deployProxy } = require('@openzeppelin/truffle-upgrades');
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
const globalConfig = require("../config/contracts/GlobalConfig");
const ppConfig = require("../config/contracts/PublicContract/PPConfig");

module.exports = async function (deployer, network) {
  if (network === 'matic' || network === "development") {
    let chain_id;
    let ChildChainManagerProxy;
    let maticId;
    if ((network === 'matic' || network === "development") && process.env.NODE_ENV == "deploy") {
      chain_id = networkConfig.goerliId;
      ChildChainManagerProxy = maticNetwork.child.ChildChainManagerProxy;
      maticId = networkConfig.maticMumbaiId;
    } else if (network === "mainMatic" && process.env.NODE_ENV == "deploy") {
      chain_id = networkConfig.etherMainId;
      ChildChainManagerProxy = "" // TODO add CHILDCHAIN
      maticId = networkConfig.maticMainId;
    }
    let decimals = config.decimals;
    let nameBET = config.betName;
    let symbolBET = config.betSymbol
    let firstWithdrawIndex = globalConfig.firstWithdrawIndex;
    let GFrewards = globalConfig.GFrewards;
    let welcomeBTYTokens = globalConfig.welcomeBTYTokens;
    let GFindex = globalConfig.GFindex;
    await deployProxy(BETTokenContract, [nameBET, symbolBET, decimals, chain_id, firstWithdrawIndex, GFrewards, welcomeBTYTokens, GFindex], { deployer, initializer: '__BETinit' });

    let nameBTY = config.btyName;
    let symbolBTY = config.btySymbol;
    await deployProxy(BTYTokenContract, [nameBTY, symbolBTY, decimals, ChildChainManagerProxy, chain_id], { deployer, initializer: '__BTYinit' });

    await deployProxy(PrivateEventContract, { deployer, initializer: '__PrivateEvents' });

    let minBet = globalConfig.minBet;
    await deployProxy(PublicEventContract, [minBet], { deployer, initializer: '__PublicEventsInit' });

    await deployProxy(MiddlePaymentContract, { deployer, initializer: '__MiddlePaymentInit' });

    let playersPersMint = ppConfig.playersPersMint;
    let playersPers = ppConfig.playersPers;
    let playersPersPremiun = ppConfig.playersPersPremiun;
    let firstRefer = ppConfig.firstRefer;
    let secontRefer = ppConfig.secontRefer;
    let thirdRefer = ppConfig.thirdRefer;
    let fakeAddr = ppConfig.fakeAddr;

    await deployProxy(PlayerPaymentContract, [
      playersPersMint,
      playersPers,
      playersPersPremiun,
      firstRefer,
      secontRefer,
      thirdRefer,
      fakeAddr
    ], { deployer, initializer: '__PlayerPaymentInit' });

    // TODO
    // await deployer.deploy(ProEventsContract, BETTokenContract.address, BTYTokenContract.address);

    // await deployer.deploy(GrowthFactorEvents);

  } else {
    return;
  }
}