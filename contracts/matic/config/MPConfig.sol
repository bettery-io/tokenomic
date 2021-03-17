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

    function setFundWallet(address payable _CMFWallet, address payable _MFWallet) public {
        require(msg.sender == owner, "owner only");
        comMarketFundWallet = _CMFWallet;
        moderatorsFundWallet = _MFWallet;
    }

    function setFundPerc(uint _dFPerc, uint _dFPPremim, uint _cMFPerc, uint _mFPerc) public {
        require(msg.sender == owner, "owner only");
        developFundPerc = _dFPerc;
        developFundPercPremim = _dFPPremim;
        comMarketFundPerc = _cMFPerc;
        moderatorsFundPerc = _mFPerc;
    }

    function setHostPerc(uint _hostPercMint, uint _hostPerc, uint _eHPerc, uint _eHPMint) public {
        require(msg.sender == owner, "owner only");
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
        extraHostPerc = _eHPerc;
        extraHostPercMint = _eHPMint;
    }

    function setExpertPerc(uint _ePercMint, uint _ePerc, uint _eExtraPerc, uint _ePremPerc) public {
        require(msg.sender == owner, "owner only");
        expertPercMint = _ePercMint;
        expertPerc = _ePerc;
        expertExtraPerc = _eExtraPerc;
        expertPremiumPerc = _ePremPerc;
    }

    function setAdvisorPerc(uint _adPercMint, uint _adPerc) public {
        require(msg.sender == owner, "owner only");
        advisorPercMint = _adPercMint;
        advisorPepc = _adPerc;
    }
    
    function setGFindex(uint _GFindex) public{
        require(msg.sender == owner, "owner only");
        GFindex = _GFindex;
    }

    function getGFindex() public view returns(uint) {
        return GFindex;
    }
}
