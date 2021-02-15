// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {PrivStruct} from "../struct/PrivStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";

contract PrivateEvent is MetaTransactLib, TimeValidation {
    constructor() MetaTransactLib("Private_contract", "1", 5) {}

    event eventIsFinish(int256 question_id, uint8 correctAnswer);
    mapping(int256 => PrivStruct.EventData) events;

    function createEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questionQuantity,
        address payable _correctAnswerSetter
    ) public payable {
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].host = msgSender();
        events[_id].correctAnswerSetter = _correctAnswerSetter;
        events[_id].questionQuantity = _questionQuantity;
    }

        function setRoleOfAdmin(
        int256 _id,
        address payable _correctAnswerSetter
    ) public payable {
        require(
            msgSender() == events[_id].host,
            "Only owner can set admin of event"
        );
        events[_id].correctAnswerSetter = _correctAnswerSetter;
    }

    function setAnswer(int256 _id, uint8 _whichAnswer) public payable {
        require(timeAnswer(events[_id].startTime, events[_id].endTime) == 0, "Time is not valid");
        PrivStruct.Participant memory parts;
        parts = PrivStruct.Participant(msgSender());
        events[_id].participant[_whichAnswer].push(parts);
    }

    function setCorrectAnswer(int256 _id, uint8 _correctAnswer) public payable{
        if(events[_id].correctAnswerSetter != address(0)){
        require(
            msgSender() == events[_id].correctAnswerSetter,
            "Only admin can set correct answer"
        );
        }

        require(timeAnswer(events[_id].startTime, events[_id].endTime) == 2, "Time is not valid");
        events[_id].correctAnswer = _correctAnswer;

        emit eventIsFinish(_id, _correctAnswer);
    }
}