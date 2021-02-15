// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {PubStruct} from "../struct/PubStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";
import {BET} from "../tokens/BET.sol";
import {BTY} from "../tokens/BTY.sol";
import {Percentages} from "../config/Percentages.sol";

contract PublicEvents is MetaTransactLib, TimeValidation, Percentages {
    address payable owner;
    mapping(int256 => PubStruct.EventData) events;

    constructor() MetaTransactLib("Public_contract", "1", 5) {
        owner = msg.sender;
    }

    function newEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questAmount,
        uint256 _amountExperts,
        bool _calculateExperts
    ) public payable {
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].questAmount = _questAmount;
        events[_id].amountExperts = _amountExperts;
        events[_id].host = _msgSender();
        events[_id].calculateExperts = _calculateExperts;
    }
}
