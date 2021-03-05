// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {PubStruct} from "../../struct/PubStruct.sol";
import {TimeValidation} from "../../helpers/TimeValidation.sol";
import {BET} from "../../tokens/BET.sol";
import {BTY} from "../../tokens/BTY.sol";
import {FinishEvent} from "./FinishEvent.sol";

contract PublicEvents is
    TimeValidation,
    PubStruct,
    FinishEvent
{
    event calculateExpert(int256 id, uint256 activePlayers);
    constructor(BET _betAddress, BTY _btyAddress) FinishEvent(_betAddress, _btyAddress){}
    uint256 minBet = 10000000000000000;

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
        if (_premium) {
            require(
                btyToken.allowance(_host, address(this)) >= _amountPremiumEvent,
                "Allowance error"
            );
            require(
                btyToken.transferFrom(
                    _host,
                    address(this),
                    _amountPremiumEvent
                ),
                "Transfer BTY tokens for PRO event error"
            );
        }
    }

    function addAdvisor(address payable _advisor, int256 _id) public ownerOnly(){
          events[_id].advisor = _advisor;
    }

    function setAnswer(
        int256 _id,
        uint8 _whichAnswer,
        uint256 _amount,
        address payable _playerWallet,
        int256 _playerId,
        uint8 _referrersDeep
    ) public payable ownerOnly() {
        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
            "Time is not valid"
        );
        require(events[_id].reverted != true, "event is reverted");
        require(events[_id].eventFinish != true, "event is finish");
        require(
            events[_id].allPlayers[_playerWallet] != true,
            "user already participate in event"
        );
        require(_amount >= minBet, "bet amount must be bigger or equal to 0.01 tokens" );

        PubStruct.Player memory player;
        player = PubStruct.Player(_playerId, _playerWallet, _amount, _referrersDeep);
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

    function setReferrers(string memory _key, address payable[] calldata _referrers) public ownerOnly(){
        referrers[_key].referrer = _referrers;
    }

    function setValidator(
        int256 _id,
        uint8 _whichAnswer,
        address payable _expertWallet,
        uint256 _reputation
    ) public payable ownerOnly() {
        require(timeValidate(events[_id].endTime) == 0, "Time is not valid");
        require(
            events[_id].allPlayers[_expertWallet] != true,
            "user already participate in event"
        );
        require(events[_id].reverted != true, "event is reverted");
        require(events[_id].eventFinish != true, "event is finish");

        if (events[_id].activePlayers == 0) {
            events[_id].reverted = true;
            emit revertedEvent(_id, "do not have players on event");
        } else {
            if (
                events[_id].calculateExperts && events[_id].amountExperts == 0
            ) {
                emit calculateExpert(_id, events[_id].activePlayers);
            } else {
                PubStruct.Expert memory expert;
                expert = PubStruct.Expert(_expertWallet, _reputation);
                events[_id].expert[_whichAnswer].push(expert);
                uint256 active = events[_id].activeExperts + 1;
                events[_id].activeExperts = active;

                if (active == events[_id].amountExperts && events[_id].amountExperts > 0) {
                    letsFindCorrectAnswer(_id);
                }
            }
        }
    }

    function setActiveExpertsFromOracl(uint256 _amount, int256 _id) public ownerOnly {
        events[_id].amountExperts = _amount;
    }

}
