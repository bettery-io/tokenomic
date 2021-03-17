const BetContract = artifacts.require("../contracts/matic/tokens/BET.sol");
const BtyContract = artifacts.require("../contracts/matic/tokens/BTY.sol");
const PublicEventContract = artifacts.require("../contracts/matic/events/PublicEvents.sol")
const Web3 = require('web3');

contract('swipe', (accounts) => {
    let betToken,
        btyToken,
        publicEvents,
        web3 = new Web3(),
        lessAmount = web3.utils.toWei(String(10), "ether"),
        owner = accounts[0]

    beforeEach(async () => {
        betToken = await BetContract.deployed();
        btyToken = await BtyContract.deployed();
        publicEvents = await PublicEventContract.deployed();
    })

    it('Should have an address for BET and BTY tokens', () => {
        assert(betToken.address && btyToken.address && publicEvents.address)
    });

    it("set addresses to the BET contract", async () => {
        let error = false;
        let btyTokenAdd = btyToken.address;
        let publicAdd = publicEvents.address;
        await betToken.setConfigContract(
            publicAdd,
            btyTokenAdd,
            {
                from: owner
            }
        ).catch((err) => {
            error = true;
            console.log(err)
        })
        assert(!error, "contract return error")
    })

    it("Mint BET token from not owner address, must be a error", async () => {
        await betToken.mint(
            owner,
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
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await betToken.mint(
            accounts[2],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })
        let firstAmount = await betToken.balanceOf(accounts[1]);
        let secondBalance = await betToken.balanceOf(accounts[2]);
        firstAmount = web3.utils.fromWei(firstAmount, "ether");
        secondBalance = web3.utils.fromWei(secondBalance, "ether");
        assert(firstAmount == 10 && secondBalance == 10, "Not enough money on balances")
    })

    it("Mint tokens twice, must be an error", async () => {
        await betToken.mint(
            accounts[6],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await betToken.mint(
            accounts[6],
            {
                from: owner
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("swipe not enough tokens, must be an error", async () => {
        let amount = web3.utils.toWei(String(1000), "ether")
        await btyToken.swipe(
            amount,
            {
                from: accounts[1]
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("withdrawal not enough tokens", async () => {
        await betToken.mint(
            accounts[5],
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
        ).catch((err) => {
            console.log(err)
        })


        await btyToken.withdraw(
            lessAmount,
            {
                from: accounts[5]
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

})