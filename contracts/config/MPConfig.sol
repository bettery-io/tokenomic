// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MPConfig {
    address owner;
    constructor() {
        owner = msg.sender;
    }

    address payable public comMarketFundWallet; // Community Market Fund wallet
    address payable public moderatorsFundWallet; // Moderators Fund wallet
    uint public developFundPerc = 10; // mint token percent for Development Fund
    uint public developFundPercPremim = 10; // pay token percent for Developement Fund in Premium events
    uint public comMarketFundPerc = 5; // 5 if advisor exist or comMarketFundPerc + advisorPercMint + extraHostPercMint = 8 if advisor not exist
    uint public moderatorsFundPerc = 2; // Moderators Fund percent to pay token
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

    uint public GFindex = 100;

    function setComMarketFundWallet(address payable _wallet) public {
        require(msg.sender == owner, "owner only");
        comMarketFundWallet = _wallet;
    }

    function setModeratorsFundWallet(address payable _wallet) public {
        require(msg.sender == owner, "owner only");
        moderatorsFundWallet = _wallet;
    }

    function setDevelopFundPerc(uint _developFundPerc) public {
        require(msg.sender == owner, "owner only");
        developFundPerc = _developFundPerc;
    }

    function setHostPerc(uint _hostPercMint, uint _hostPerc) public {
        require(msg.sender == owner, "owner only");
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
    }

    function setExpertPerc(uint _expertPerc) public {
        require(msg.sender == owner, "owner only");
        expertPerc = _expertPerc;
    }

    function setGFindex(uint _GFindex) public{
        require(msg.sender == owner, "owner only");
        GFindex = _GFindex;
    }

    function getGFindex() public view returns(uint) {
        return GFindex;
    }
}
