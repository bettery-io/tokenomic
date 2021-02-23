// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ConfigVariables {
    uint256 private companyPerc;
    uint256 private hostPerc;
    uint256 private expertPerc;
    uint256 private playerPers;
    address private owner;
    uint256 private firstWithdrawIndex = 10;
    uint256 private GFrewards = 100000000000000000000;
    uint256 private GFindex = 1;
    uint256 private welcomeBTYTokens = 10000000000000000000;

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

    function setHostPerc(uint256 _hostPerc) public ownerOnly() {
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

    function getCompanyPerc() public view returns (uint256) {
        return companyPerc;
    }

    function getHostPerc() public view returns (uint256) {
        return hostPerc;
    }

    function getExpertPerc() public view returns (uint256) {
        return expertPerc;
    }

    function getPlayerPers() public view returns (uint256) {
        return playerPers;
    }

    function getFirstWithdraw() public view returns (uint256) {
        return welcomeBTYTokens * firstWithdrawIndex;
    }

    function getGFrewards() public view returns (uint256) {
        return GFrewards;
    }

    function getGFindex() public view returns (uint256) {
        return GFindex;
    }

    function getWelcomeBTYTokens() public view returns (uint256) {
        return welcomeBTYTokens;
    }
}
