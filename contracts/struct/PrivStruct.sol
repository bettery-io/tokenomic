// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library PrivStruct {
    struct Player {
        address payable players;
    }

    struct EventData {
        int256 id;
        uint256 startTime;
        uint256 endTime;
        uint8 correctAnswer;
        mapping(uint256 => Player[]) player;
        uint8 questionQuantity;
        address payable host;
        address payable correctAnswerSetter;
    }
}
