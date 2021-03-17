// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PPConfig {
    address owner;
    constructor() {
        owner = msg.sender;
    }

    // PLAYERS
    uint public playersPersMint = 50; // mint token percent for players
    uint public playersPers = 90; // pay token percent for players
    uint public playersPersPremiun = 75; // pay token percent for players in Premium events
    uint public firstRefer = 4; // first level of referrers;
    uint public secontRefer = 4; // second level of referrers;
    uint public thirdRefer = 2; // third level of referrers;

    address fakeAddr = 0x45e505a6e7e367288Dc1796dFFdA0A68fb29CB0f;

    function setPlayerPercMint(uint _playersPersMint, uint _playersPers, uint _playersPersPremiun) public {
        require(msg.sender == owner, "owner only");
        playersPersMint = _playersPersMint;
        playersPers = _playersPers;
        playersPersPremiun = _playersPersPremiun;
    }

    function setReferrersPerc(uint _firstRefer, uint _secontRefer, uint _thirdRefer) public {
        require(msg.sender == owner, "owner only");
        firstRefer = _firstRefer;
        secontRefer = _secontRefer;
        thirdRefer = _thirdRefer;
    }

    function setFakeAddr(address _fake) public{
        require(msg.sender == owner, "owner only");
        fakeAddr = _fake;
    }
}