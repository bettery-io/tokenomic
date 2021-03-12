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

    function setPlayerPersMint(uint _playersPersMint) public {
        require(msg.sender == owner, "owner only");
        playersPersMint = _playersPersMint;
    }


}