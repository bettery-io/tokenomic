const truffleAssert = require('truffle-assertions');

const PublicContract = artifacts.require("../contracts/events/PublicEvents/PublicEvents.sol");
const MiddlePayment = artifacts.require("../contracts/events/PublicEvents/MiddlePayment.sol")
const BtyContract = artifacts.require("../contracts/tokens/BTY.sol");
const BetContract = artifacts.require("../contracts/tokens/BET.sol");
const Web3 = require('web3');

contract('Public Events', (accounts) => {
    let events,
        bty,
        bet,
        web3 = new Web3(),
        owner = accounts[0],
        players = 7,
        pool = 0,
        correctAnswer = 1,
        mintTokens,
        allReputation = 0


    function getPercent(percent, from) {
        return (from * percent) / 100;
    }


    it('Deploy bty token', async () => {
        bty = await BtyContract.deployed();
        assert(bty.address, "not deployed")
    })

    it('Deploy bet token', async () => {
        bet = await BetContract.deployed();
        assert(bet.address, "not deployed")
    })

    it('Deploy public contract token', async () => {
        events = await PublicContract.deployed(bet.address, bty.address);
        assert(events.address, "not deployed")
    })

    it('Deploy finish event token', async () => {
        middleEvent = await MiddlePayment.deployed(bet.address, bty.address);
        assert(middleEvent.address, "not deployed")
    })

    it("Set addresses to the BET contract", async () => {
        let error = false;
        let btyTokenAdd = bty.address;
        let address = middleEvent.address;
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

        await events.setMPStructAdd(address,
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
        await middleEvent.setComMarketFundWallet(
            accounts[1],
            {
                from: owner
            }).catch((err) => {
                console.log(err)
            })

        await middleEvent.setModeratorsFundWallet(
            accounts[2],
            {
                from: owner
            }).catch((err) => {
                console.log(err)
            })

        let comMarketFundWallet = await middleEvent.comMarketFundWallet({ from: owner });
        let moderatorsFundWallet = await middleEvent.moderatorsFundWallet({ from: owner });
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
        let afterBalance = 0;
        for (let i = 0; i < players; i++) {
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
        let id = 1,
            tx

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);
        for (let i = players; i < accounts.length; i++) {
            let whichAnswer = correctAnswer,
                expertWallet = accounts[i],
                reputation = i

            allReputation += i;

            tx = await events.setValidator(
                id,
                whichAnswer,
                expertWallet,
                reputation,
                {
                    from: owner
                }
            ).catch((err) => {
                console.log(err);
            })
        }
        truffleAssert.eventEmitted(tx, 'findCorrectAnswer', (ev) => {
            return ev.id.toString() == String(id);
        }, 'Contract should return the correct id.');
    })

    it("check minted tokens amount", async () => {
        let GFindex = await middleEvent.getGFindex({ from: owner })
        let controversy = (100 - players);
        let averageBet = pool / players;
        let tokens = (averageBet * players * controversy * Number(GFindex.toString())) / 10000;
        let id = 1;
        let tx = await middleEvent.letsFindCorrectAnswer(
            id,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        truffleAssert.eventEmitted(tx, 'payToCompanies', (ev) => {
            mintTokens = web3.utils.fromWei(ev.tokens.toString(), "ether");
            return Number(mintTokens).toFixed(2) == tokens.toFixed(2) && ev.correctAnswer.toString() == correctAnswer.toString()
        }, 'Contract do not have correct tokens on blance.');
    })

    it("check amount payed to companies", async () => {
        let mintedTokens = Number(Number(mintTokens).toFixed(2)),
            mintDF = getPercent(mintedTokens, 10),
            mintCMF = getPercent(mintedTokens, 8),
            mintMF = getPercent(mintedTokens, 2),
            id = 1

        let tx = await middleEvent.letsPayToCompanies(
            id,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        truffleAssert.eventEmitted(tx, 'payToHost', (ev) => {
            let mintDFc = web3.utils.fromWei(ev.mintDF.toString(), "ether"),
                mintCMFc = web3.utils.fromWei(ev.mintCMF.toString(), "ether"),
                mintMFc = web3.utils.fromWei(ev.mintMF.toString(), "ether")

            return mintDF.toFixed(2) == Number(mintDFc).toFixed(2) &&
                mintCMF.toFixed(2) == Number(mintCMFc).toFixed(2) &&
                mintMF.toFixed(2) == Number(mintMFc).toFixed(2)

        }, 'Contract do not pay correct tokens to the companies.');
    })

    it("Check payment to validators", async () => {
        let id = 1,
            percentPay = 7,
            expertPercMint = 10,
            beforeBalance = 0
            afterBalance = 0,
            mintedTokens = Number(Number(mintTokens).toFixed(2))
        let tx = await middleEvent.letsPayToExperts(
            id,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        for(let i = players; i < accounts.length; i++) { 
            let mintToken = (getPercent(mintedTokens, expertPercMint) * i) / allReputation;
            let payToken = (getPercent(pool, percentPay) * i) / allReputation;
            beforeBalance = mintToken + payToken + beforeBalance + 10 
        }
        console.log(beforeBalance);

        for (let i = players; i < accounts.length; i++) {
            let bal = await bet.balanceOf(accounts[i], { from: accounts[i] }).catch(err => { console.log(err) })
            bal = web3.utils.fromWei(bal, "ether");
            afterBalance = afterBalance + Number(Number(bal).toFixed(2))
        }

        console.log(afterBalance);

        truffleAssert.eventEmitted(tx, 'payToHost', (ev) => {
            return ev.id.toString() == String(id);
        }, 'Contract do not return correct id.');

        assert(beforeBalance == afterBalance, "Balances are not correct")

    })

})