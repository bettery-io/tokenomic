// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {PrivStruct} from "../struct/PrivStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";

contract PrivateEvents is TimeValidation, ConfigVariables {
    constructor() {}

    event eventIsFinish(int256 question_id, uint8 correctAnswer);
    mapping(int256 => PrivStruct.EventData) events;

    function createEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questionQuantity,
        address _host
    ) public ownerOnly() {
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].host = _host;
        events[_id].questionQuantity = _questionQuantity;
    }

    function setRoleOfAdmin(int256 _id, address _correctAnswerSetter)
        public
        ownerOnly()
    {
        events[_id].correctAnswerSetter = _correctAnswerSetter;
    }

    function setAnswer(
        int256 _id,
        uint8 _whichAnswer,
        address _playerWallet
    ) public ownerOnly() {
        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
            "Time is not valid for players"
        );
        require(
            events[_id].allPlayers[_playerWallet] != true,
            "user already participate in event"
        );

        PrivStruct.Player memory play;
        play = PrivStruct.Player(_playerWallet);
        events[_id].allPlayers[_playerWallet] = true;
        events[_id].player[_whichAnswer].push(play);
    }

    function setCorrectAnswer(
        int256 _id,
        uint8 _correctAnswer,
        address _expertWallet
    ) public ownerOnly() {
        if (events[_id].correctAnswerSetter != address(0)) {
            require(
                _expertWallet == events[_id].correctAnswerSetter,
                "Wallet setter of corect answer is incorrect"
            );
        }

        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 2,
            "Time is not valid for expert"
        );
        require(
            events[_id].allPlayers[_expertWallet] != true,
            "user already participate in event"
        );
        events[_id].correctAnswer = _correctAnswer;

        emit eventIsFinish(_id, _correctAnswer);
    }
}
