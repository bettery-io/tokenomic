// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//TODO
library ProStruct {
    struct Player {
        address payable players;
        uint256 amount;
        uint8 reputation;
    }

    struct EventData {
        int256 id;
        address payable host;
        uint256 startTime;
        uint256 endTime;
        uint8 questAmount;
        uint256 amount;
        mapping(uint256 => Player[]) player;
        mapping(address => bool) allPlayers; // added for validation if players whant ot be expers
        uint256 activePlayers; // amount of all players
        bool eventFinish;
        uint8 correctAnswer;
        uint256 pool;
    }
}