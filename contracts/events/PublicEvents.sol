// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {PubStruct} from "../struct/PubStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";
import {BET} from "../tokens/BET.sol";
import {BTY} from "../tokens/BTY.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";
import {Libs} from "../helpers/Libs.sol";

contract PublicEvents is
    MetaTransactLib,
    TimeValidation,
    ConfigVariables,
    Libs
{
    address payable owner;
    BET private betToken;
    BTY private btyToken;

    mapping(int256 => PubStruct.EventData) events;
    event revertedEvent(int256 id, string purpose);

    constructor(BET _betAddress, BTY _btyAddress)
        MetaTransactLib("Public_contract", "1", 5)
    {
        owner = msg.sender;
        betToken = _betAddress;
        btyToken = _btyAddress;
    }

    function newEvent(
        int256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint8 _questAmount,
        uint256 _amountExperts,
        bool _calculateExperts,
        address payable _host,
        bool _premium,
        uint256 _amountPremiumEvent
    ) public payable ownerOnly() {
        events[_id].id = _id;
        events[_id].startTime = _startTime;
        events[_id].endTime = _endTime;
        events[_id].questAmount = _questAmount;
        events[_id].amountExperts = _amountExperts;
        events[_id].host = _host;
        events[_id].calculateExperts = _calculateExperts;
        events[_id].premium = _premium;

        // TODO add Advisor
        if (_premium) {
            require(
                btyToken.allowance(_host, address(this)) >= _amountPremiumEvent,
                "Allowance error"
            );
            require(
                btyToken.transferFrom(_host, address(this), _amountPremiumEvent),
                "Transfer BTY tokens for PRO event error"
            );
        }
    }

    function setAnswer(
        int256 _id,
        uint8 _whichAnswer,
        uint256 _amount,
        address payable _playerWallet
    ) public payable ownerOnly() {
        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
            "Time is not valid"
        );
        require(events[_id].reverted, "event is reverted");
        require(events[_id].eventFinish, "event is finish");

        PubStruct.Player memory player;
        // TODO add Referrers
        player = PubStruct.Player(_playerWallet, _amount);
        events[_id].players[_whichAnswer].push(player);
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

    function setValidator(
        int256 _id,
        uint8 _whichAnswer,
        address payable _expertWallet,
        int256 rating
    ) public payable ownerOnly() {
        require(timeValidate(events[_id].endTime) == 0, "Time is not valid");
        require(
            events[_id].allPlayers[_expertWallet] == true,
            "user already participate in event"
        );
        require(events[_id].reverted, "event is reverted");
        require(events[_id].eventFinish, "event is finish");

        if (events[_id].activePlayers == 0) {
            events[_id].reverted = true;
            emit revertedEvent(_id, "do not players");
        } else {
            if (events[_id].calculateExperts) {
                events[_id].amountExperts = calculateExpertAmount(
                    events[_id].activePlayers
                );
            }
            PubStruct.Expert memory expert;
            expert = PubStruct.Expert(_expertWallet, rating);
            events[_id].expert[_whichAnswer].push(expert);
            uint256 active = events[_id].activeExperts + 1;
            if (active == events[_id].amountExperts) {
                events[_id].activeExperts = active;
                letsFindCorrectAnswer(_id);
            } else {
                events[_id].activeExperts = active;
            }
        }
    }

    function letsFindCorrectAnswer(int256 _id) private {
        uint256 biggestValue = 0;
        uint256 correctAnswer;

        // find correct answer
        for (uint8 i = 0; i < events[_id].questAmount; i++) {
            if (events[_id].expert[i].length > biggestValue) {
                biggestValue = events[_id].expert[i].length;
                correctAnswer = i;
            }
        }

        findDuplicates(
            correctAnswer,
            biggestValue,
            _id,
            events[_id].questAmount
        );
    }

    function findDuplicates(
        uint256 correctAnswer,
        uint256 biggestValue,
        int256 _id,
        uint8 questAmount
    ) private {
        if (events[_id].activeExperts > 1) {
            uint8 duplicatesAnswers = 0;
            uint256[] memory expertAnswers = new uint256[](questAmount);
            for (uint8 i = 0; i < questAmount; i++) {
                expertAnswers[i] = events[_id].expert[i].length;
            }

            setSort(expertAnswers);
            sort();

            for (uint8 i = 0; i < sortedArray.length - 1; i++) {
                if ((i + 1) < sortedArray.length) {
                    if (sortedArray[i + 1] == sortedArray[i]) {
                        if (biggestValue == sortedArray[i]) {
                            duplicatesAnswers++;
                        }
                    }
                }
            }

            if (duplicatesAnswers > 0) {
                events[_id].reverted = true;
                revertPayment(_id, "duplicates validators");
            } else {
                events[_id].correctAnswer = correctAnswer;
                findLosersPool(_id);
            }
        } else {
            events[_id].correctAnswer = correctAnswer;
            findLosersPool(_id);
        }
    }

    function revertedPayment(int256 _id, string memory purpose)
        public
        ownerOnly()
    {
        revertPayment(_id, purpose);
    }

    function revertPayment(int256 _id, string memory purpose) private {
        for (uint8 i = 0; i < events[_id].questAmount; i++) {
            for (uint8 z = 0; z < events[_id].players[i].length; z++) {
                require(
                    betToken.transfer(
                        events[_id].players[i][z].player,
                        events[_id].players[i][z].amount
                    ),
                    "Revert BET token to players is error"
                );
            }
        }
        events[_id].reverted = true;
        emit revertedEvent(_id, purpose);
    }

    function findLosersPool(int256 _id) private {}
}
