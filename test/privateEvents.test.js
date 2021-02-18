const ProEventsContract = artifacts.require("../contracts/events/PrivateEvents.sol")

contract('privateEvents', (accounts) => {
    let event,
        owner = accounts[0],
        questionQuantity = 3,
        correctAnswerSetter = accounts[2],
        host = accounts[1]

    beforeEach(async () => {
        event = await ProEventsContract.deployed();
    })

    it('Should have an address for Private Event', () => {
        assert(event.address)
    });

    it("Only owner can create event", async () => {
        let startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 3),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            id = 1231

        await event.createEvent(
            id,
            startTime,
            endTime,
            questionQuantity,
            host,
            {
                from: accounts[3]
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    });

    it("Set to event incorrect address to answer setter", async () => {
        let startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 3),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            id = 1232

        await event.createEvent(
            id,
            startTime,
            endTime,
            questionQuantity,
            host,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await event.setRoleOfAdmin(
            id,
            correctAnswerSetter,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await event.setAnswer(
            id,
            0,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await event.setCorrectAnswer(
            id,
            1,
            accounts[8],
            {
                from: owner
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("Event must successfully finish with expert wallet exist", async () => {
        let startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 2),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            error = false,
            id = 1233

        await event.createEvent(
            id,
            startTime,
            endTime,
            questionQuantity,
            host,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
            error = true;
        })

        await event.setRoleOfAdmin(
            id,
            correctAnswerSetter,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
            error = true;
        })

        await event.setAnswer(
            id,
            0,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
            error = true;
        })

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(3000);

        await event.setCorrectAnswer(
            id,
            1,
            correctAnswerSetter,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
            error = true;
        })

        assert(!error, "contract return error")
    })

    it("Set answer from the user that already participated in the event", async () => {
        let startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 3),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            id = 1234

        await event.createEvent(
            id,
            startTime,
            endTime,
            questionQuantity,
            host,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await event.setAnswer(
            id,
            0,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err)
        })

        await event.setAnswer(
            id,
            0,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

    it("Event must successfully finish, everybody can be expert", async () => {
        let startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 2),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            error = false,
            id = 1235

        await event.createEvent(
            id,
            startTime,
            endTime,
            questionQuantity,
            host,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err);
            error = true;
        })

        await event.setAnswer(
            id,
            0,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err);
            error = true;
        })

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(3000);

        await event.setCorrectAnswer(
            id,
            1,
            accounts[9],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err);
            error = true;
        })

        assert(!error, "contract return error")
    })

    it("Set correct answer from player address, must be a error", async () => {
        let startTime = Number(Math.floor(Date.now() / 1000).toFixed(0)),
            date = new Date().setSeconds(new Date().getSeconds() + 2),
            endTime = Number(Math.floor(date / 1000).toFixed(0)),
            id = 1236

        await event.createEvent(
            id,
            startTime,
            endTime,
            questionQuantity,
            host,
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err);
        })

        await event.setAnswer(
            id,
            0,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            console.log(err);
        })

        function timeout(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        await timeout(3000);

        await event.setCorrectAnswer(
            id,
            1,
            accounts[5],
            {
                from: owner
            }
        ).catch((err) => {
            assert(err.message.indexOf('revert') >= 0, 'error message must contain revert');
        })
    })

})