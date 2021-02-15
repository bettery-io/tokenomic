const PublicEventContract = artifacts.require("PublicEvent.sol");
const PrivateEventContract = artifacts.require("PrivateEvent.sol");
const BetteryTokenContract = artifacts.require("BetteryToken.sol");
const maticNetwork = require("../config/matic.json");
const config = require("../config/tokenConfig");

module.exports = async function (deployer, network) {

  if (network === 'matic' || network === "development") {

  }else{
    return;
  }
}