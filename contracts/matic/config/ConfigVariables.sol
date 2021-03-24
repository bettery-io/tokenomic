// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract ConfigVariables is Initializable {

    uint public firstWithdrawIndex; 
    uint public GFrewards;
    uint public welcomeBTYTokens;
    address payable public owner; // Bettery Development Fund wallet

    uint public GFindex;


    function __ConfigVariables(
        uint _firstWithdrawIndex,
        uint _GFrewards,
        uint _welcomeBTYTokens,
        uint _GFindex
        ) public initializer {
        owner = msg.sender;
        firstWithdrawIndex = _firstWithdrawIndex;
        GFrewards = _GFrewards;
        welcomeBTYTokens = _welcomeBTYTokens;
        GFindex = _GFindex;
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

    function setGFindex(uint256 _GFindex) public ownerOnly() {
        GFindex = _GFindex;
    }

    function getGFindex() public view returns (uint256) {
        return GFindex;
    }
}
