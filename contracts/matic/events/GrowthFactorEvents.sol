// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {GFStruct} from "../struct/GFStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";

contract GrowthFactorEvents is TimeValidation {

    mapping(int256 => GFStruct.EventData) events;
    event GFIsFinish(int256 _id, uint8 correctAnswer);
    address owner;

    constructor(){
        owner = msg.sender;
    }

    function createEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questAmount
    ) public {
        require( msg.sender == owner, "owner only");
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].questAmount = _questAmount;
    } 

    function setAnswer(
        int256 _id,
        uint8 _whichAnswer,
        address payable _playerWallet,
        uint8 _reputation
    ) public {
        require( msg.sender == owner, "owner only");
        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
            "Time not valid"
        );
        GFStruct.Player memory play;
        play = GFStruct.Player(_playerWallet, _reputation);
        events[_id].player[_whichAnswer].push(play);
    }

    function finishGFEvent(int256 _id) public {
        require( msg.sender == owner, "owner only");
        uint256 biggestValue = 0;
        uint8 correctAnswer;

        // find correct answer
        for (uint8 i = 0; i < events[_id].questAmount; i++) {
            if (events[_id].player[i].length > biggestValue) {
                biggestValue = events[_id].player[i].length;
                correctAnswer = i;
            }
        }

        // add payment for players
      //  uint256 GFrewards = getGFrewards();

        events[_id].correctAnswer = correctAnswer;
        events[_id].eventFinish = true;
        emit GFIsFinish(_id, correctAnswer);
    }
    

}    