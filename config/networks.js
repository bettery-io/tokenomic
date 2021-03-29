const keys = require("./keys");

let maticMumbai = "wss://ws-mumbai.matic.today",
    maticMumbaiId = 80001,
    maticMain = "wss://ws-mainnet.matic.network",
    maticMainId = 137,
    goerli = `wss://goerli.infura.io/ws/v3/${keys.infura}`,
    goerliId = 5,
    etherMain = `wss://mainnet.infura.io/ws/v3/${keys.infura}`,
    etherMainId = 1


module.exports = {
    maticMumbai,
    maticMumbaiId,
    maticMain,
    maticMainId,
    goerli,
    goerliId,
    etherMainId,
    etherMain
}