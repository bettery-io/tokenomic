const { readFileSync } = require('fs')
const path = require('path')
const HDWalletProvider = require('@truffle/hdwallet-provider')
const config = require("./config/networks");

module.exports = {
  networks: {
    mainnet: {
      provider: () => {
        const mnemonic = readFileSync(path.join(__dirname, './keys/goerli_mnemonic'), 'utf-8')
        return new HDWalletProvider(mnemonic, config.etherMain)
      },
      network_id: config.etherMainId,
      gasPrice: 15000000001,
      skipDryRun: true
    },
    goerli: {
      provider: () => {
        const mnemonic = readFileSync(path.join(__dirname, './keys/goerli_mnemonic'), 'utf-8')
        return new HDWalletProvider(mnemonic, config.goerli, 0, 10)
      },
      network_id: config.goerliId,
      gasPrice: 15000000001
    },
    mainMatic: {
      matic: {
        provider: () => {
          const mnemonic = readFileSync(path.join(__dirname, './keys/goerli_mnemonic'), 'utf-8')
          return new HDWalletProvider(mnemonic, config.maticMain)
        },
        network_id: config.maticMainId,
        gasPrice: 0,
        confirmations: 2,
        timeoutBlocks: 200,
        skipDryRun: true
      },
    },
    matic: {
      provider: () => {
        const mnemonic = readFileSync(path.join(__dirname, './keys/goerli_mnemonic'), 'utf-8')
        return new HDWalletProvider(mnemonic, config.maticMumbai)
      },
      network_id: config.maticMumbaiId,
      gasPrice: 0,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
  },
  compilers: {
    solc: {
      version: "0.7.6",    // Fetch exact version from solc-bin (default: truffle's version)
      docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  },
  plugins: [
    'truffle-contract-size'
  ]
}
