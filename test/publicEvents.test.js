const truffleAssert = require('truffle-assertions');

const PublicContract = artifacts.require("../contracts/events/PublicEvents/PublicEvents.sol");
const FinishEvent = artifacts.require("../contracts/events/PublicEvents/FinishEvent.sol")
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
        finishEvent = await FinishEvent.deployed(bet.address, bty.address);
    })

    it('Should have an address for Public Events', () => {
        assert(events.address && bty.address && bet.address);
    });

    it("Set addresses to the BET contract", async () => {
        let error = false;
        let btyTokenAdd = bty.address;
        let address = finishEvent.address;
        await bet.setConfigContract(
            address,
            btyTokenAdd,
            {
                from: owner
            }
        ).catch((err) => {
            error = true;
            console.log(err)
        })

        await events.setEFStructAdd(address,
            {
                from: owner
            }
        ).catch((err) => {
            error = true;
            console.log(err)
        })

        assert(!error, "contract return error")
    })

    it("Set addresses to market fund and exetra", async () => {
        await events.setComMarketFundWallet(
            accounts[1],
            {
                from: owner
            }).catch((err) => {
                console.log(err)
            })

        await events.setModeratorsFundWallet(
            accounts[2],
            {
                from: owner
            }).catch((err) => {
                console.log(err)
            })

        let comMarketFundWallet = await events.comMarketFundWallet({ from: owner });
        let moderatorsFundWallet = await events.moderatorsFundWallet({ from: owner });
        assert(comMarketFundWallet && moderatorsFundWallet, "do not have wallets")
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

        assert(balance == accounts.length * 10, "balance is not " + accounts.length * 10 + " tokens")
    })

    it("Create event", async () => {
        let id = 1,
            startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 5),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            questAmount = 3,
            amountExperts = 3,
            calculateExperts = false,
            host = accounts[1],
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
        for (let i = 0; i < 7; i++) {
            beforeBalance = beforeBalance + 10;
            let id = 1,
                betAmount = i % 2 == 0 ? 4 : 8,
                whichAnswer = i > 4 ? 1 : 0,
                amount = web3.utils.toWei(String(betAmount), "ether"),
                playerWallet = accounts[i],
                playerId = 123 + i,
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
        assert(beforeBalance == pool + afterBalance, "Balances are not equal")
    })

    it("let's validate", async () => {
        let error = false

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);
        let tx;
        for (let i = 7; i < accounts.length; i++) {
            let id = 1,
                whichAnswer = 0,
                expertWallet = accounts[i],
                reputation = i
            tx = await events.setValidator(
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
        truffleAssert.eventEmitted(tx, 'findCorrectAnswer', (ev) => {
            return ev.id === id;
        }, 'Contract should return the correct id.');
    })

    // it("check balances", async () => {
    //     for (i = 0; i < 10; i++) {
    //         let bal = await bet.balanceOf(accounts[i], { from: accounts[i] }).catch(err => { console.log(err) })
    //         bal = web3.utils.fromWei(bal, "ether");
    //         console.log(bal);
    //     }
    //     assert(false, "error")
    // })

    it("check finish event", async () => {
        let id = 1;
        let tx = await finishEvent.letsFindCorrectAnswer(
            id,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        truffleAssert.eventEmitted(tx, 'payToCompanies', (ev) => {
            console.log(ev);
        }, 'Contract should return the correct id.');
    })

})