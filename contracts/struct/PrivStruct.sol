// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library PrivStruct {
    struct Participant {
        address payable participants;
    }

    struct EventData {
        int256 id;
        uint256 startTime;
        uint256 endTime;
        uint8 correctAnswer;
        mapping(uint256 => Participant[]) participant;
        uint8 questionQuantity;
        address payable host;
        address payable correctAnswerSetter;
    }
}
