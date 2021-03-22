// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ProStruct} from "../struct/ProStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";
import {BET} from "../tokens/BET.sol";
import {BTY} from "../tokens/BTY.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract ProEvents is TimeValidation, Initializable {
    BET private betToken;
    BTY private btyToken;
    address owner;

    mapping(int256 => ProStruct.EventData) events;

    function __ProEventsInit(BET _betAddress, BTY _btyAddress)
        public
        initializer
    {
        betToken = _betAddress;
        btyToken = _btyAddress;
        owner = msg.sender;
    }

    function newEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questAmount,
        address payable _host,
        uint256 _prizeAmount,
        bool _eventFinishWay,
        uint256 _playersNeeded
    ) public payable {
        require(msg.sender == owner, "owner only");
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].questAmount = _questAmount;
        events[_id].host = _host;
        events[_id].prizeAmount = _prizeAmount;
        events[_id].eventFinishWay = _eventFinishWay;
        events[_id].playersNeeded = _playersNeeded;

        require(
            btyToken.allowance(_host, address(this)) >= _prizeAmount,
            "Allowance error"
        );
        require(
            btyToken.transferFrom(_host, address(this), _prizeAmount),
            "Transfer BTY tokens for PRO event error"
        );
    }

    function setAnswer(
        int256 _id,
        uint8 _whichAnswer,
        address payable _playerWallet,
        uint8 _reputation
    ) public payable {
        require(msg.sender == owner, "owner only");
        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
            "Time is not valid"
        );
        require(events[_id].eventFinish, "event is finish");
        require(
            events[_id].allPlayers[_playerWallet] == true,
            "user already participate in event"
        );

        ProStruct.Player memory player;
        player = ProStruct.Player(_playerWallet, _reputation);
        events[_id].player[_whichAnswer].push(player);
        events[_id].allPlayers[_playerWallet] = true;
        events[_id].activePlayers += 1;
    }

    //TODO add event finish logic
}
