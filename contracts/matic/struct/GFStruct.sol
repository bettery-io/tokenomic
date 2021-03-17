// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//TODO
library GFStruct {
    struct Player {
        address payable players;
        uint8 reputation;
    }

    struct EventData {
        int256 id;
        uint256 startTime;
        uint256 endTime;
        uint8 questAmount;
        mapping(uint256 => Player[]) player;
        bool eventFinish;
        uint8 correctAnswer;
    }
}