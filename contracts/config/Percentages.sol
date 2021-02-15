// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Percentages {
    uint256 private companyPerc;
    uint256 private hostPerc;
    uint256 private expertPerc;
    uint256 private playerPers;
    address private owner;

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

    function getCompanyPerc() public view returns(uint256) {
        return companyPerc;
    }

    function setHostPerc() public view returns(uint256)  {
        return hostPerc;
    }

    function setExpertPerc() public view returns(uint256)  {
        return expertPerc;
    }

    function setPlayerPers() public view returns(uint256) {
        return playerPers;
    }
}
