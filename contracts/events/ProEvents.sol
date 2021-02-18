// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ProStruct} from "../struct/ProStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";
import {BET} from "../tokens/BET.sol";
import {BTY} from "../tokens/BTY.sol";

contract ProEvents is TimeValidation, ConfigVariables {
    BET private betToken;
    BTY private btyToken;

    mapping(int256 => ProStruct.EventData) events;

    constructor(BET _betAddress, BTY _btyAddress) {
        betToken = _betAddress;
        btyToken = _btyAddress;
    }

    function newEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questAmount,
        address payable _host,
        uint256 _amount
    ) public payable ownerOnly() {
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].questAmount = _questAmount;
        events[_id].host = _host;

        require(
            btyToken.allowance(_host, address(this)) >= _amount,
            "Allowance error"
        );
        require(
            btyToken.transferFrom(_host, address(this), _amount),
            "Transfer BTY tokens for PRO event error"
        );
    }

    function setAnswer(
        int256 _id,
        uint8 _whichAnswer,
        uint256 _amount,
        address payable _playerWallet,
        uint8 _reputation
    ) public payable ownerOnly() {
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
        player = ProStruct.Player(_playerWallet, _amount, _reputation);
        events[_id].player[_whichAnswer].push(player);
        events[_id].allPlayers[_playerWallet] = true;
        events[_id].activePlayers += 1;
        events[_id].pool += _amount;

        require(
            betToken.allowance(_playerWallet, address(this)) >= _amount,
            "Allowance error"
        );
        require(
            betToken.transferFrom(_playerWallet, address(this), _amount),
            "Transfer BTY from players error"
        );
    }

    //TODO add event finish logic


}
