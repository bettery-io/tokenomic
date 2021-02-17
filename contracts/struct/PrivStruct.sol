// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library PrivStruct {
    struct Player {
        address players;
    }

    struct EventData {
        int256 id;
        uint256 startTime;
        uint256 endTime;
        uint8 correctAnswer;
        mapping(uint256 => Player[]) player;
        uint8 questionQuantity;
        address host;
        address correctAnswerSetter;
    }
}
