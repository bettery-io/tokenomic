// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ConfigVariables {
    // HOST
    uint256 public hostPercMint = 10; // mint token percent for host 
    uint256 public hostPerc = 4; // pay token percent for host
    uint256 public extraHostPerc = 1; // if advisor exist we add extra coins to host
    uint256 public extraHostPercMint = 1; // if advisor exist we add extra coins to host in mint token
    // EXPERT
    uint256 public expertPercMint = 10; // mint token percent for expert 
    uint256 public expertPerc = 4; // pay token percent for expert 
    uint256 public expertExtraPerc = 2; // extra pay token parcent for expert if advisor not exist
    uint256 public expertPremiumPerc = 15; // bty percent in premium events for experts
    // ADVISORS
    uint256 public advisorPercMint = 2; // mint token parcent for advisor 
    uint256 public advisorPepc = 1;  // pay token parcent for advisor 
    // PLAYERS
    uint256 public playersPersMint = 50; // mint token percent for players
    uint256 public playersPers = 90; // pay token percent for players
    uint256 public playersPersPremiun = 75; // pay token percent for players in Premium events

    uint256 public firstWithdrawIndex = 10; 
    uint256 public GFrewards = 100000000000000000000;
    uint256 public GFindex = 1;
    uint256 public welcomeBTYTokens = 10000000000000000000;
    // Bettery Development Fund
    address payable public owner; // Bettery Development Fund wallet
    uint256 public developFundPerc = 10; // mint token percent for Development Fund
    uint256 public developFundPercPremim = 10; // pay token percent for Developement Fund in Premium events
    // Community Market Fund
    address payable public comMarketFundWallet; // Community Market Fund wallet
    uint256 public comMarketFundPerc = 5; // 5 if advisor exist or comMarketFundPerc + advisorPercMint + extraHostPercMint = 8 if advisor not exist
    // Moderators Fund
    address payable public moderatorsFundWallet; // Moderators Fund wallet
    uint256 public moderatorsFundPerc = 2; // Moderators Fund percent to pay token

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

    function setDevelopFundPerc(uint256 _developFundPerc) public ownerOnly() {
        developFundPerc = _developFundPerc;
    }

    function setHostPerc(uint256 _hostPercMint, uint256 _hostPerc) public ownerOnly() {
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
    }

    function setExpertPerc(uint256 _expertPerc) public ownerOnly() {
        expertPerc = _expertPerc;
    }

    function setPlayerPersMint(uint256 _playersPersMint) public ownerOnly() {
        playersPersMint = _playersPersMint;
    }

    function setFirstWithdraw(uint256 _firstWithdrawIndex) public ownerOnly() {
        firstWithdrawIndex = _firstWithdrawIndex;
    }

    function setGFrewards(uint256 _GFrewards) public ownerOnly() {
        GFrewards = _GFrewards;
    }

    function setWelcomeBTYTokens(uint256 _welcomeBTYTokens) public ownerOnly() {
        welcomeBTYTokens = _welcomeBTYTokens;
    }

    function setGFindex(uint256 _GFindex) public ownerOnly() {
        GFindex = _GFindex;
    }

    function getFirstWithdraw() public view returns (uint256) {
        return welcomeBTYTokens * firstWithdrawIndex;
    }
}
