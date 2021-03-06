const truffleAssert = require('truffle-assertions');

const PublicContract = artifacts.require("../contracts/matic/events/PublicEvents/PublicEvents.sol");
const MiddlePayment = artifacts.require("../contracts/matic/events/PublicEvents/MiddlePayment.sol")
const PlayerPay = artifacts.require("../contracts/matic/events/PublicEvents/PlayerPayment.sol")
const BtyContract = artifacts.require("../contracts/matic/tokens/BTY.sol");
const BetContract = artifacts.require("../contracts/matic/tokens/BET.sol");
const Web3 = require('web3');

contract('Public Events', (accounts) => {
    let events,
        bty,
        bet,
        web3 = new Web3(),
        owner = accounts[0],
        CMDWallet = accounts[1],
        MFWallet = accounts[2],
        host = accounts[3],
        players = 11,
        pool = 0,
        correctAnswer = 1,
        mintTokens = 0,
        allReputation = 0,
        maxValidIndex = 14,
        avarageBet = 0,
        calcMintedToken = 0,
        activePlayers = 0


    it('Deploy bty token', async () => {
        bty = await BtyContract.deployed();
        assert(bty.address, "not deployed")
    })

    it('Deploy bet token', async () => {
        bet = await BetContract.deployed();
        assert(bet.address, "not deployed")
    })

    it('Deploy public contract', async () => {
        events = await PublicContract.deployed(bet.address, bty.address);
        assert(events.address, "not deployed")
    })

    it('Deploy middle event', async () => {
        middleEvent = await MiddlePayment.deployed(events.address);
        assert(middleEvent.address, "not deployed")
    })

    it('Deploy player pay', async () => {
        playerPayEvent = await PlayerPay.deployed(events.address, middleEvent.address);
        assert(playerPayEvent.address, "not deployed")
    })

    it("Set addresses to contract", async () => {
        let error = false;
        let btyTokenAdd = bty.address;
        let eventAddr = events.address;
        let MPAddr = middleEvent.address;
        let PPAddr = playerPayEvent.address;
        await bet.setConfigContract(
            eventAddr,
            btyTokenAdd,
            {
                from: owner
            }
        ).catch((err) => {
            error = true;
            console.log(err)
        })

        await events.setAddresses(
            MPAddr,
            PPAddr,
            {
                from: owner
            }
        ).catch((err) => {
            error = true;
            console.log(err)
        })

        await middleEvent.setAddresses(
            eventAddr,
            PPAddr,
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
        await middleEvent.setFundWallet(
            CMDWallet,
            MFWallet,
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

    it("Validate without players, contract must be reverted", async () => {
        let id = 1;

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);
        let whichAnswer = correctAnswer,
            expertWallet = accounts[8],
            reputation = 1


        let tx = await events.setValidator(
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

        truffleAssert.eventEmitted(tx, 'revertedEvent', (ev) => {
            return ev.purpose == 'do not have players';
        }, 'Contract must be reverted.');
    })

    it("Create second event", async () => {
        let id = 2,
            startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 5),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            questAmount = 3,
            amountExperts = 3,
            calculateExperts = false,
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
        let id = 2,
            betAmount = 3,
            whichAnswer = 1,
            amount = web3.utils.toWei(String(betAmount), "ether"),
            playerWallet = accounts[3]

        await bet.approve(events.address, amount, { from: playerWallet }).catch((err) => console.log(err))

        await events.setAnswer(
            id,
            whichAnswer,
            amount,
            playerWallet,
            { from: owner }
        ).catch((err) => {
            console.log(err)
        })

        let bal = await bet.balanceOf(playerWallet, { from: playerWallet }).catch(err => { console.log(err) })
        bal = web3.utils.fromWei(bal, "ether");
        assert(bal == "7", "Balances are not 7")
    })

    it("Validate without players, contract must be reverted", async () => {
        let id = 2;

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);
        let whichAnswer = correctAnswer,
            expertWallet = accounts[8],
            reputation = 1


        let tx = await events.setValidator(
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

        truffleAssert.eventEmitted(tx, 'revertedEvent', (ev) => {
            return ev.purpose == "only one player on event"
        }, 'Contract must be reverted.');

        let playerWallet = accounts[3];
        let bal = await bet.balanceOf(playerWallet, { from: playerWallet }).catch(err => { console.log(err) })
        bal = web3.utils.fromWei(bal, "ether");
        assert(bal == "10", "balance is not 10")
    })

    it("Create third event", async () => {
        let id = 3,
            startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 5),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            questAmount = 3,
            amountExperts = 5,
            calculateExperts = false,
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

    function expertAnswers(i) {
        if (i == 10) {
            return 1
        } else {
            return i % 2 == 0 ? 2 : 0
        }
    }

    it("check duplicates of validators", async () => {
        let id = 3;
        for (let i = 0; i < 6; i++) {
            let betAmount = i + 1,
                whichAnswer = i % 2 == 0 ? 1 : 0,
                amount = web3.utils.toWei(String(betAmount), "ether"),
                playerWallet = accounts[i];

            await bet.approve(events.address, amount, { from: playerWallet }).catch((err) => console.log(err))

            await events.setAnswer(
                id,
                whichAnswer,
                amount,
                playerWallet,
                { from: owner }
            ).catch((err) => {
                console.log(err)
            })
        }

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);

        let tx;

        for (let i = 6; i < 11; i++) {
            let whichAnswer = expertAnswers(i),
                expWallet = accounts[i],
                reputation = i;

            tx = await events.setValidator(
                id,
                whichAnswer,
                expWallet,
                reputation,
                {
                    from: owner
                }
            ).catch((err) => {
                console.log(err);
            })
        }

        truffleAssert.eventEmitted(tx, 'findCorrectAnswer', (ev) => {
            return ev.id == id;
        }, 'Contract contain correct id.');

        let tx2 = await middleEvent.letsFindCorrectAnswer(id, { from: owner }).catch((err) => {
            console.log(err)
        })

        truffleAssert.eventEmitted(tx2, 'revertedEvent', (ev) => {
            return ev.purpose == 'duplicat expert';
        }, 'Contract must be reverted.');


        let balances = 0;
        for (let i = 0; i < 6; i++) {
            let bal = await bet.balanceOf(accounts[i], { from: accounts[i] }).catch(err => { console.log(err) })
            bal = web3.utils.fromWei(bal, "ether");
            balances += Number(bal);
        }
        assert(balances == 60, "Balances are not 50")
    })

    it("Create four event", async () => {
        let id = 4,
            startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 5),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            questAmount = 3,
            amountExperts = 5,
            calculateExperts = false,
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

    it("check if all users answer only one answer", async () => {
        let id = 4;
        for (let i = 0; i < 6; i++) {
            let betAmount = i + 1,
                whichAnswer = 0,
                amount = web3.utils.toWei(String(betAmount), "ether"),
                playerWallet = accounts[i];

            await bet.approve(events.address, amount, { from: playerWallet }).catch((err) => console.log(err))

            await events.setAnswer(
                id,
                whichAnswer,
                amount,
                playerWallet,
                { from: owner }
            ).catch((err) => {
                console.log(err)
            })
        }

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);

        let tx;

        for (let i = 6; i < 11; i++) {
            let whichAnswer = 1,
                expWallet = accounts[i],
                reputation = i;

            tx = await events.setValidator(
                id,
                whichAnswer,
                expWallet,
                reputation,
                {
                    from: owner
                }
            ).catch((err) => {
                console.log(err);
            })
        }

        truffleAssert.eventEmitted(tx, 'findCorrectAnswer', (ev) => {
            return ev.id == id;
        }, 'Contract contain correct id.');

        let tx2 = await middleEvent.letsFindCorrectAnswer(id, { from: owner }).catch((err) => {
            console.log(err)
        })

        truffleAssert.eventEmitted(tx2, 'revertedEvent', (ev) => {
            return ev.purpose = 'play chose one answer';
        }, 'Contract must be reverted.');


        let balances = 0;
        for (let i = 0; i < 6; i++) {
            let bal = await bet.balanceOf(accounts[i], { from: accounts[i] }).catch(err => { console.log(err) })
            bal = web3.utils.fromWei(bal, "ether");
            balances += Number(bal);
        }
        assert(balances == 60, "Balances are not 50")
    })

    it("Create five event", async () => {
        let id = 5,
            startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 5),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            questAmount = 3,
            amountExperts = 5,
            calculateExperts = false,
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

    it("check if no one choose correct answer", async () => {
        let id = 5;
        for (let i = 0; i < 6; i++) {
            let betAmount = i + 1,
                whichAnswer = 0,
                amount = web3.utils.toWei(String(betAmount), "ether"),
                playerWallet = accounts[i];

            await bet.approve(events.address, amount, { from: playerWallet }).catch((err) => console.log(err))

            await events.setAnswer(
                id,
                whichAnswer,
                amount,
                playerWallet,
                { from: owner }
            ).catch((err) => {
                console.log(err)
            })
        }

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(5000);

        let tx;

        for (let i = 6; i < 11; i++) {
            let whichAnswer = 0,
                expWallet = accounts[i],
                reputation = i;

            tx = await events.setValidator(
                id,
                whichAnswer,
                expWallet,
                reputation,
                {
                    from: owner
                }
            ).catch((err) => {
                console.log(err);
            })
        }

        truffleAssert.eventEmitted(tx, 'findCorrectAnswer', (ev) => {
            return ev.id == id;
        }, 'Contract contain correct id.');

        let tx2 = await middleEvent.letsFindCorrectAnswer(id, { from: owner }).catch((err) => {
            console.log(err)
        })

        truffleAssert.eventEmitted(tx2, 'revertedEvent', (ev) => {
            return ev.purpose = 'play chose one answer';
        }, 'Contract must be reverted.');


        let balances = 0;
        for (let i = 0; i < 6; i++) {
            let bal = await bet.balanceOf(accounts[i], { from: accounts[i] }).catch(err => { console.log(err) })
            bal = web3.utils.fromWei(bal, "ether");
            balances += Number(bal);
        }
        assert(balances == 60, "Balances are not 50")

    })


})