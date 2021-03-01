// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ConfigVariables {
    uint256 public communityMarketingFund; // 8 or 5 and 2 for advisor + 1 additional for host
    uint256 public companyPerc = 10; 
    uint256 public hostPercMint = 10;
    uint256 public hostPerc = 4;
    uint256 public expertPercMint = 10;
    uint256 public expertPerc = 4;
    uint256 public expertExptraPerc = 2;
    uint256 public advisorPercMint = 2;
    uint256 public advisorPepc = 1;
    uint256 public playerPers;
    address public owner;
    uint256 public firstWithdrawIndex = 10;
    uint256 public GFrewards = 100000000000000000000;
    uint256 public GFindex = 1;
    uint256 public welcomeBTYTokens = 10000000000000000000;

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

    function setCompanyPerc(uint256 _companyPerc) public ownerOnly() {
        companyPerc = _companyPerc;
    }

    function setHostPerc(uint256 _hostPercMint, uint256 _hostPerc) public ownerOnly() {
        hostPercMint = _hostPercMint;
        hostPerc = _hostPerc;
    }

    function setExpertPerc(uint256 _expertPerc) public ownerOnly() {
        expertPerc = _expertPerc;
    }

    function setPlayerPers(uint256 _playerPers) public ownerOnly() {
        playerPers = _playerPers;
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
