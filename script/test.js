const Web3 = require('web3');
const { readFileSync } = require('fs');
const path = require('path');
const tokeSale = require("../build/contracts/QuizeTokenSale.json");

async function connectToNetwork(provider) {
    let web3 = new Web3(provider);
    let privateKey = readFileSync(path.join(__dirname, '../keys/goerli_private_key'), 'utf-8')
    const prKey = web3.eth.accounts.privateKeyToAccount('0x' + privateKey);
    await web3.eth.accounts.wallet.add(prKey);
    let accounts = await web3.eth.accounts.wallet;
    let account = accounts[0].address;
    return { web3, account };
}

async function init(contract) {
    let network = "wss://goerli.infura.io/ws/v3/2b5ec85db4a74c8d8ed304ff2398690d",
        networkId = 5;

    let { web3, account } = await connectToNetwork(network);
    let abi = contract.abi;
    let address = contract.networks[networkId].address;
    return new web3.eth.Contract(abi, address, { from: account });
}

async function test() {
    let contract = await init(tokeSale);
    let test = await contract.methods.test3().call()
    console.log(test);
}

test();