const PublicContract = artifacts.require("../contracts/events/PublicEvents/PublicEvents.sol");
const BtyContract = artifacts.require("../contracts/tokens/BTY.sol");
const BetContract = artifacts.require("../contracts/tokens/BET.sol");
const Web3 = require('web3');

contract('Public Events', (accounts) => {
    let events,
        bty,
        bet,
        web3 = new Web3(),
        owner = accounts[0]


    beforeEach(async () => {
        bty = await BtyContract.deployed();
        bet = await BetContract.deployed();
        events = await PublicContract.deployed(bet.address, bty.address);
    })

    it('Should have an address for Public Events', () => {
        assert(events.address && bty.address && bet.address);
    });

    it("Set addresses to the BET contract", async () => {
        let error = false;
        let btyTokenAdd = bty.address;
        let publicAdd = events.address;
        await bet.setConfigContract(
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

    it("Check name of tokens", async () => {
        let name = await bet.symbol({ from: owner });
        assert(name == "BET", "contract return error")
    })

    it("Mint tokens to new users", async () => {
        let balance = 0;
        for (let i = 0; i < accounts.length; i++) {
            await bet.mint(accounts[i], { from: owner }).catch(err => { console.log(err) })
            let bal = await bet.balanceOf(accounts[i], { from: accounts[i] }).catch(err => { console.log(err) })
            bal = web3.utils.fromWei(bal, "ether");
            balance = balance + Number(bal);
        }

        assert(balance == accounts.length * 10, "balance is not 100 tokens")
    })

    it("Create event", async () => {
        let id = 1,
            startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 3),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            questAmount = 3,
            amountExperts = 3,
            calculateExperts = false,
            host = accounts[1],
            premium = false,
            amountPremiumEvent = 0,
            error = false
        await events.newEvent(
            id,
            startTime,
            endTime,
            questAmount,
            amountExperts,
            calculateExperts,
            host,
            premium,
            amountPremiumEvent,
            {
                from: owner
            }
        ).catch((err) => {
            error = true;
            console.log(err)
        })
        assert(!error, "contract return error")
    })

    it("let's participate", async () => {
        let beforeBalance = 0;
        let pool = 0;
        let afterBalance = 0;
        for (let i = 0; i < 8; i++) {
            beforeBalance = beforeBalance + 10;
            let id = 1,
                betAmount = i + 1,
                whichAnswer = i > 6 ? 1 : 0,
                amount = web3.utils.toWei(String(betAmount), "ether"),
                playerWallet = accounts[i],
                playerId = 123,
                referrersDeep = 0

            await bet.approve(events.address, amount, { from: playerWallet }).catch((err) => console.log(err))

            await events.setAnswer(
                id,
                whichAnswer,
                amount,
                playerWallet,
                playerId,
                referrersDeep,
                { from: owner }
            ).catch((err) => {
                console.log(err)
            })

            let bal = await bet.balanceOf(playerWallet, { from: playerWallet }).catch(err => { console.log(err) })
            bal = web3.utils.fromWei(bal, "ether");
            afterBalance = afterBalance + Number(bal)
            pool = pool + betAmount;
        }
        console.log(beforeBalance);
        console.log(pool);
        console.log(afterBalance);

        assert(beforeBalance == pool + afterBalance, "Balances are not equal")

    })

    it("let's validate from not company account, must contain error", async () => {
        let id = 1,
            whichAnswer = 0,
            expertWallet = accounts[2],
            reputation = 1,
            error = false

        await events.setValidator(
            id,
            whichAnswer,
            expertWallet,
            reputation,
            {
                from: expertWallet
            }
        ).catch((err) => {
            error = true
        })
        assert(error, "contract must contrain error")
    })

    it("let's validate", async () => {
        let error = false

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(3000);
        for (let i = 8; i < 11; i++) {
            let id = 1,
                whichAnswer = 0,
                expertWallet = accounts[i],
                reputation = 1

            await events.setValidator(
                id,
                whichAnswer,
                expertWallet,
                reputation,
                {
                    from: owner
                }
            ).catch((err) => {
                error = true
                console.log(err);
            })
        }
        assert(!error, "contract must get parameters without errors")
    })

})