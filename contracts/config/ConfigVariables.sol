// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ConfigVariables {

    uint public firstWithdrawIndex = 10; 
    uint public GFrewards = 100000000000000000000;
    uint public welcomeBTYTokens = 10000000000000000000;
    address payable public owner; // Bettery Development Fund wallet


    constructor() {
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(
            msg.sender == owner,
            "This function could only be executed by the owner"
        );
        _;
    }

    function setFirstWithdraw(uint _firstWithdrawIndex) public ownerOnly() {
        firstWithdrawIndex = _firstWithdrawIndex;
    }

    function setGFrewards(uint _GFrewards) public ownerOnly() {
        GFrewards = _GFrewards;
    }

    function setWelcomeBTYTokens(uint _welcomeBTYTokens) public ownerOnly() {
        welcomeBTYTokens = _welcomeBTYTokens;
    }

    function getFirstWithdraw() public view returns (uint) {
        return welcomeBTYTokens * firstWithdrawIndex;
    }
}
