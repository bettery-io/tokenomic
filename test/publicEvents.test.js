const PublicContract = artifacts.require("../contracts/events/PublicEvents/PublicEvents.sol")

contract('Public Events', (accounts) => {
    let events,
        owner = accounts[0]


    beforeEach(async () => {
        events = await PublicContract.deployed();
    })

    it('Should have an address for Public Events', () => {
        assert(events.address)
    });

})