// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//TODO
library ProStruct {
    struct Player {
        address payable players;
        uint8 reputation; 
    }

    struct EventData {
        int256 id;
        address payable host;
        uint256 startTime;
        uint256 endTime;
        uint8 questAmount; // question amount
        uint256 prizeAmount; 
        mapping(uint256 => Player[]) player;
        mapping(address => bool) allPlayers; // added for validation if players whant participate more
        uint256 activePlayers; // amount of all players
        uint8 correctAnswer;
        uint256 playersNeeded; // amount of players that need for finish event, can't be 0 if eventFinishWay = false
        uint256 reputPool; // reputation pool for calcalation 
        bool eventFinish;
        bool eventFinishWay; // true finish by time, false finish by active usert
    }
}