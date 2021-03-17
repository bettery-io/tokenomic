const GFContract = artifacts.require("../contracts/matic/events/GrowthFactorEvents.sol")

contract('Growth Factor Events', (accounts) => {
    let gf,
        owner = accounts[0]


    beforeEach(async () => {
        gf = await GFContract.deployed();
    })

    it('Should have an address for Growth Factor Events', () => {
        assert(gf.address)
    });

})