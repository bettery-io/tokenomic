const BetContract = artifacts.require("../contracts/tokens/BET.sol")
const BtyContract = artifacts.require("../contracts/tokens/BTY.sol")
const Web3 = require('web3');

contract('swipe', (accounts) => {
    let betToken,
        btyToken,
        web3 = new Web3(),
        lessAmount = web3.utils.toWei(String(10), "ether"),
        enoughAmount = web3.utils.toWei(String(100), "ether"),
        owner = accounts[0]

    beforeEach(async () => {
        betToken = await BetContract.deployed();
        btyToken = await BtyContract.deployed();
    })

    it('Should have an address for BET and BTY tokens', () => {
        assert(betToken.address && btyToken.address)
    });

    it("Mint BET token from not owner address, must be a error", async () => {
        await betToken.mint(
            owner,
            lessAmount,
            {
                from: accounts[2]
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("Mint BET Token from onwer address", async () => {
        await betToken.mint(
            accounts[1],
            lessAmount,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await betToken.mint(
            accounts[2],
            enoughAmount,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })
        let firstAmount = await betToken.balanceOf(accounts[1]);
        let secondBalance = await betToken.balanceOf(accounts[2]);
        firstAmount = web3.utils.fromWei(firstAmount, "ether"),
        secondBalance = web3.utils.fromWei(secondBalance, "ether"),
        assert(firstAmount == 10 && secondBalance == 100, "Not enough money on balances")
    })
    
    it("swipe not enough tokens, must be an error", async () =>{
        let amount = web3.utils.toWei(String(1000), "ether")
        await btyToken.swipe(
            amount,
            {
                from: accounts[1]
            }
        ).catch((err)=>{
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("swipe enough tokens", async () =>{
        await btyToken.swipe(
            lessAmount,
            {
                from: accounts[1]
            }
        ).catch((err)=>{
            console.log(err)
        })
        let swipeAmount = await btyToken.balanceOf(accounts[1]);
        swipeAmount = web3.utils.fromWei(swipeAmount, "ether");
        let betAmount = await betToken.balanceOf(accounts[1]);
        betAmount = web3.utils.fromWei(String(betAmount), "ether");
        assert(swipeAmount == 10 && betAmount == 0, "balances not corrects");
    })

    it("withdrawal not enough tokens", async () =>{
        await betToken.mint(
            accounts[5],
            lessAmount,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await btyToken.swipe(
            lessAmount,
            {
                from: accounts[5]
            }
        ).catch((err)=>{
            console.log(err)
        })


        await btyToken.withdraw(
            lessAmount,
            {
                from: accounts[5]
            }
        ).catch((err)=>{
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("2 withdrawal with enough money on balance and first withdrawal", async () =>{
        let amount = web3.utils.toWei(String(1000), "ether");
        let user = accounts[6]
        await betToken.mint(
            user,
            amount,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await btyToken.swipe(
            amount,
            {
                from: user
            }
        ).catch((err)=>{
            console.log(err)
        })

        let firstWithdrawal = web3.utils.toWei(String(100), "ether");

        await btyToken.withdraw(
            firstWithdrawal,
            {
                from: user
            }
        ).catch((err)=>{
            console.log(err)
        })

        let secondWithdrawal = web3.utils.toWei(String(10), "ether");

        await btyToken.withdraw(
            secondWithdrawal,
            {
                from: user
            }
        ).catch((err)=>{
            console.log(err)
        })

        let balance = await btyToken.balanceOf(user);
        balance = web3.utils.fromWei(balance, "ether");
        assert(balance == 890, "balance is not correct")
    })

})