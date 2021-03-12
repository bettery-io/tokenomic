// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ConfigVariables {
    // HOST
    uint public hostPercMint = 10; // mint token percent for host 
    uint public hostPerc = 4; // pay token percent for host
    uint public extraHostPerc = 1; // if advisor exist we add extra coins to host
    uint public extraHostPercMint = 1; // if advisor exist we add extra coins to host in mint token
    // EXPERT
    uint public expertPercMint = 10; // mint token percent for expert 
    uint public expertPerc = 4; // pay token percent for expert 
    uint public expertExtraPerc = 2; // extra pay token parcent for expert if advisor not exist
    uint public expertPremiumPerc = 15; // bty percent in premium events for experts
    // ADVISORS
    uint public advisorPercMint = 2; // mint token parcent for advisor 
    uint public advisorPepc = 1;  // pay token parcent for advisor 
    // PLAYERS
    uint public playersPersMint = 50; // mint token percent for players
    uint public playersPers = 90; // pay token percent for players
    uint public playersPersPremiun = 75; // pay token percent for players in Premium events

    uint public firstWithdrawIndex = 10; 
    uint public GFrewards = 100000000000000000000;
    uint public GFindex = 100;
    uint public welcomeBTYTokens = 10000000000000000000;
    // Bettery Development Fund
    address payable public owner; // Bettery Development Fund wallet
    uint public developFundPerc = 10; // mint token percent for Development Fund
    uint public developFundPercPremim = 10; // pay token percent for Developement Fund in Premium events
    uint public comMarketFundPerc = 5; // 5 if advisor exist or comMarketFundPerc + advisorPercMint + extraHostPercMint = 8 if advisor not exist
    uint public moderatorsFundPerc = 2; // Moderators Fund percent to pay token

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

    function setDevelopFundPerc(uint _developFundPerc) public ownerOnly() {
        developFundPerc = _developFundPerc;
    }

    function setHostPerc(uint _hostPercMint, uint _hostPerc) public ownerOnly() {
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
    }

    function setExpertPerc(uint _expertPerc) public ownerOnly() {
        expertPerc = _expertPerc;
    }

    function setPlayerPersMint(uint _playersPersMint) public ownerOnly() {
        playersPersMint = _playersPersMint;
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

    function setGFindex(uint _GFindex) public ownerOnly() {
        GFindex = _GFindex;
    }

    function getGFindex() public ownerOnly() view returns(uint) {
        return GFindex;
    }

    function getFirstWithdraw() public view returns (uint) {
        return welcomeBTYTokens * firstWithdrawIndex;
    }
}
