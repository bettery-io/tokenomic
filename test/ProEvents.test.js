const ProContract = artifacts.require("../contracts/events/ProEvents.sol")

contract('PRO Events', (accounts) => {
    let proEvents,
        owner = accounts[0]


    beforeEach(async () => {
        proEvents = await ProContract.deployed();
    })

    it('Should have an address for Pro Events', () => {
        assert(proEvents.address)
    });

})