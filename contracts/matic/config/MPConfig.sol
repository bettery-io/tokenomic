// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract MPConfig is Initializable {
    address owner;
    address payable public comMarketFundWallet; // Community Market Fund wallet
    address payable public moderatorsFundWallet; // Moderators Fund wallet
    uint256 public developFundPerc; // mint token percent for Development Fund
    uint256 public developFundPercPremim; // pay token percent for Developement Fund in Premium events
    uint256 public comMarketFundPerc; // 5 if advisor exist or comMarketFundPerc + advisorPercMint + extraHostPercMint = 8 if advisor not exist
    uint256 public moderatorsFundPerc; // Moderators Fund percent to pay token
    // HOST
    uint256 public hostPercMint; // mint token percent for host
    uint256 public hostPerc; // pay token percent for host
    uint256 public extraHostPerc; // if advisor exist we add extra coins to host
    uint256 public extraHostPercMint; // if advisor exist we add extra coins to host in mint token
    // EXPERT
    uint256 public expertPercMint; // mint token percent for expert
    uint256 public expertPerc; // pay token percent for expert
    uint256 public expertExtraPerc; // extra pay token parcent for expert if advisor not exist
    uint256 public expertPremiumPerc; // bty percent in premium events for experts
    // ADVISORS
    uint256 public advisorPercMint; // mint token parcent for advisor
    uint256 public advisorPepc; // pay token parcent for advisor

    uint256 public GFindex;

    function __MPConfigInit(
        uint256 _developFundPerc,
        uint256 _developFundPercPremim,
        uint256 _comMarketFundPerc,
        uint256 _moderatorsFundPerc,
        uint256 _hostPercMint,
        uint256 _hostPerc,
        uint256 _extraHostPerc,
        uint256 _extraHostPercMint,
        uint256 _expertPercMint,
        uint256 _expertPerc,
        uint256 _expertExtraPerc,
        uint256 _expertPremiumPerc,
        uint256 _advisorPercMint,
        uint256 _advisorPepc,
        uint256 _GFindex
    ) public initializer {
        owner = msg.sender;
        developFundPerc = _developFundPerc;
        developFundPercPremim = _developFundPercPremim;
        comMarketFundPerc = _comMarketFundPerc;
        moderatorsFundPerc = _moderatorsFundPerc;
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
        extraHostPerc = _extraHostPerc;
        extraHostPercMint = _extraHostPercMint;
        expertPercMint = _expertPercMint;
        expertPerc = _expertPerc;
        expertExtraPerc = _expertExtraPerc;
        expertPremiumPerc = _expertPremiumPerc;
        advisorPercMint = _advisorPercMint;
        advisorPepc = _advisorPepc;
        GFindex = _GFindex;
    }

    function setFundWallet(
        address payable _CMFWallet,
        address payable _MFWallet
    ) public {
        require(msg.sender == owner, "owner only");
        comMarketFundWallet = _CMFWallet;
        moderatorsFundWallet = _MFWallet;
    }

    function setFundPerc(
        uint256 _dFPerc,
        uint256 _dFPPremim,
        uint256 _cMFPerc,
        uint256 _mFPerc
    ) public {
        require(msg.sender == owner, "owner only");
        developFundPerc = _dFPerc;
        developFundPercPremim = _dFPPremim;
        comMarketFundPerc = _cMFPerc;
        moderatorsFundPerc = _mFPerc;
    }

    function setHostPerc(
        uint256 _hostPercMint,
        uint256 _hostPerc,
        uint256 _eHPerc,
        uint256 _eHPMint
    ) public {
        require(msg.sender == owner, "owner only");
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
        extraHostPerc = _eHPerc;
        extraHostPercMint = _eHPMint;
    }

    function setExpertPerc(
        uint256 _ePercMint,
        uint256 _ePerc,
        uint256 _eExtraPerc,
        uint256 _ePremPerc
    ) public {
        require(msg.sender == owner, "owner only");
        expertPercMint = _ePercMint;
        expertPerc = _ePerc;
        expertExtraPerc = _eExtraPerc;
        expertPremiumPerc = _ePremPerc;
    }

    function setAdvisorPerc(uint256 _adPercMint, uint256 _adPerc) public {
        require(msg.sender == owner, "owner only");
        advisorPercMint = _adPercMint;
        advisorPepc = _adPerc;
    }

    function setGFindex(uint256 _GFindex) public {
        require(msg.sender == owner, "owner only");
        GFindex = _GFindex;
    }

    function getGFindex() public view returns (uint256) {
        return GFindex;
    }
}
