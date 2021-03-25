const BTY = require("../build/contracts/BTY.json");
const BET = require("../build/contracts/BET.json");
const PublicEvents = require("../build/contracts/PublicEvents.json");
const MiddlePayment = require("../build/contracts/MiddlePayment.json");
const PlayerPayment = require("../build/contracts/PlayerPayment.json");

const contract = require("./contractInit");
const mpConfig = require("../config/contracts/PublicContract/MPConfig");
const networkConfig = require("../config/networks");

const setConfiguration = async () => {
    let prodaction = "test"; // TODO switch to the prodaction
    await setBetConfig(prodaction);
    await setBtyConfig(prodaction);
    await setPublicConfig(prodaction);
    await setMiddlePaymentConfig(prodaction);
    await PlayerPaymentConfig(prodaction);
    console.log("FINISH");
    process.exit();
}

const setBetConfig = async (from) => {
    try {
        let networkId = from == "main" ? networkConfig.maticMainId : networkConfig.maticMumbaiId;
        let contr = await contract.init(from, BET);
        let publicEventsAddr = PublicEvents.networks[networkId].address;
        let btyAddr = BTY.networks[networkId].address;
        let gasEstimate = await contr.methods.setConfigContract(publicEventsAddr, btyAddr).estimateGas();
        let tx = await contr.methods.setConfigContract(publicEventsAddr, btyAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setBetConfig: ", err)
    }
}

const setBtyConfig = async (from) =>{
    try {
        let networkId = from == "main" ? networkConfig.maticMainId : networkConfig.maticMumbaiId;
        let contr = await contract.init(from, BTY);
        let betAddr = BET.networks[networkId].address;
        let gasEstimate = await contr.methods.setBETaddr(betAddr).estimateGas();
        let tx = await contr.methods.setBETaddr(betAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setBtyConfig: ", err)
    }
}

const setPublicConfig = async (from) => {
    try {
        let networkId = from == "main" ? networkConfig.maticMainId : networkConfig.maticMumbaiId;
        let contr = await contract.init(from, PublicEvents);
        let MPAddr = MiddlePayment.networks[networkId].address;
        let PPAddr = PlayerPayment.networks[networkId].address;
        let betAddr = BET.networks[networkId].address;
        let btyAddr = BTY.networks[networkId].address;
        let gasEstimate = await contr.methods.setAddresses(MPAddr, PPAddr, betAddr, btyAddr).estimateGas();
        let tx = await contr.methods.setAddresses(MPAddr, PPAddr, betAddr, btyAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setPublicConfig: ", err)
    }
}

const setMiddlePaymentConfig = async (from) => {
    let networkId = from == "main" ? networkConfig.maticMainId : networkConfig.maticMumbaiId;
    let contr = await contract.init(from, MiddlePayment);
    try {
        let PEAddr = PublicEvents.networks[networkId].address;
        let PPAddr = PlayerPayment.networks[networkId].address;
        let gasEstimate = await contr.methods.setAddresses(PEAddr, PPAddr).estimateGas();
        let tx = await contr.methods.setAddresses(PEAddr, PPAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setMiddlePaymentConfig setAddresses: ", err)
    }

    try {
        let PEAddr = PublicEvents.networks[networkId].address;
        let gasEstimate = await contr.methods.setAddr(PEAddr).estimateGas();
        let tx = await contr.methods.setAddr(PEAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setMiddlePaymentConfig setAddr: ", err)
    }

    try {
        let advisorPercMint = mpConfig.advisorPercMint;
        let advisorPepc = mpConfig.advisorPepc;
        let gasEstimate = await contr.methods.setAdvisorPerc(advisorPercMint, advisorPepc).estimateGas();
        let tx = await contr.methods.setAdvisorPerc(advisorPercMint, advisorPepc).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setAdvisorPerc setAddresses: ", err)
    }

    try {
        let expertPercMint = mpConfig.expertPercMint;
        let expertPerc = mpConfig.expertPerc;
        let expertExtraPerc = mpConfig.expertExtraPerc;
        let expertPremiumPerc = mpConfig.expertPremiumPerc;
        let gasEstimate = await contr.methods.setExpertPerc(expertPercMint, expertPerc, expertExtraPerc, expertPremiumPerc).estimateGas();
        let tx = await contr.methods.setExpertPerc(expertPercMint, expertPerc, expertExtraPerc, expertPremiumPerc).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setMiddlePaymentConfig setExpertPerc: ", err)
    }

    try {
        let hostPercMint = mpConfig.hostPercMint;
        let hostPerc = mpConfig.hostPerc;
        let extraHostPerc = mpConfig.extraHostPerc;
        let extraHostPercMint = mpConfig.extraHostPercMint;
        let gasEstimate = await contr.methods.setHostPerc(hostPercMint, hostPerc, extraHostPerc, extraHostPercMint).estimateGas();
        let tx = await contr.methods.setHostPerc(hostPercMint, hostPerc, extraHostPerc, extraHostPercMint).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setMiddlePaymentConfig setHostPerc: ", err)
    }

    try {
        let developFundPerc = mpConfig.developFundPerc;
        let developFundPercPremim = mpConfig.developFundPercPremim;
        let comMarketFundPerc = mpConfig.comMarketFundPerc;
        let moderatorsFundPerc = mpConfig.moderatorsFundPerc;
        let gasEstimate = await contr.methods.setFundPerc(developFundPerc, developFundPercPremim, comMarketFundPerc, moderatorsFundPerc).estimateGas();
        let tx = await contr.methods.setFundPerc(developFundPerc, developFundPercPremim, comMarketFundPerc, moderatorsFundPerc).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setMiddlePaymentConfig setFundPerc: ", err)
    }

    try {
        let comMarketFundAddr = mpConfig.comMarketFundAddr;
        let moderatorsFundAddr = mpConfig.moderatorsFundAddr;
        let gasEstimate = await contr.methods.setFundWallet(comMarketFundAddr, moderatorsFundAddr).estimateGas();
        let tx = await contr.methods.setFundWallet(comMarketFundAddr, moderatorsFundAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from setMiddlePaymentConfig setFundWallet: ", err)
    }
}

const PlayerPaymentConfig = async (from) => {
    let networkId = from == "main" ? networkConfig.maticMainId : networkConfig.maticMumbaiId;
    let contr = await contract.init(from, PlayerPayment);
    try {
        let PubAddr = PublicEvents.networks[networkId].address;
        let MPAddr = MiddlePayment.networks[networkId].address;
        let gasEstimate = await contr.methods.setAddr(PubAddr, MPAddr).estimateGas();
        let tx = await contr.methods.setAddr(PubAddr, MPAddr).send({
            gas: gasEstimate,
            gasPrice: 0
        });
        console.log(tx);
    } catch (err) {
        console.log("from PlayerPaymentConfig: ", err)
    }
}


setConfiguration();
