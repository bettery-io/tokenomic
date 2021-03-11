// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {TimeValidation} from "../../helpers/TimeValidation.sol";
import {FinishEvent} from "./FinishEvent.sol";
import {BET} from "../../tokens/BET.sol";
import {BTY} from "../../tokens/BTY.sol";

contract PublicEvents is
    TimeValidation,
    FinishEvent
{
    event calculateExpert(int256 id, uint256 activePlayers);
    event findCorrectAnswer(int256 id);
    
    constructor(BET _betAdres, BTY _btyAdres) FinishEvent(_betAdres, _btyAdres){}
    uint256 minBet = 10000000000000000;

    function newEvent(
        int256 _id,
        uint256 _sT,
        uint256 _eT,
        uint8 _questAmount,
        uint256 _amountExp,
        bool _calcExp,
        address payable _host,
        bool _premium,
        uint256 _amountPrem
    ) public payable ownerOnly() {
        events[_id].id = _id;
        events[_id].startTime = _sT;
        events[_id].endTime = _eT;
        events[_id].questAmount = _questAmount;
        events[_id].amountExperts = _amountExp;
        events[_id].host = _host;
        events[_id].calculateExperts = _calcExp;
        events[_id].premium = _premium;
        if (_premium) {
            require(
                btyToken.allowance(_host, address(this)) >= _amountPrem,
                "AE" // Allowance error
            );
            require(
                btyToken.transferFrom(
                    _host,
                    address(this),
                    _amountPrem
                ),
                "BTY PRO event"
            );
        }
    }

    function addAdvisor(address payable _advisor, int256 _id) public ownerOnly(){
          events[_id].advisor = _advisor;
    }

    function setAnswer(
        int256 _id,
        uint8 _answer,
        uint256 _amount,
        address payable _pWallet,
        int256 _playerId,
        uint8 _refDeep
    ) public payable ownerOnly() {
        require(
            timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
            "NVT" // not valid time
        );
        require(!events[_id].reverted, "reverted");
        require(!events[_id].eventFinish, "finished");
        require(
            !events[_id].allPlayers[_pWallet],
            "user exist"
        );
        require(_amount >= minBet, "amount" );
        uint256 ap = events[_id].activePlayers;
        events[_id].players[_answer][ap].playerId = _playerId;
        events[_id].players[_answer][ap].player = _pWallet;
        events[_id].players[_answer][ap].amount = _amount;
        events[_id].players[_answer][ap].referrersDeep = _refDeep;
        events[_id].allPlayers[_pWallet] = true;
        events[_id].activePlayers += 1;
        events[_id].pool += _amount;

        require(
            betToken.allowance(_pWallet, address(this)) >= _amount,
            "AE"
        );
        require(
            betToken.transferFrom(_pWallet, address(this), _amount),
            "BTY players"
        );
    }

    function setReferrers(string memory _key, address payable[] calldata _referrers) public ownerOnly(){
        referrers[_key].referrer = _referrers;
    }

    function setValidator(
        int256 _id,
        uint8 _answer,
        address payable _eWallet,
        int256 _reput
    ) public payable ownerOnly() {
        require(timeValidate(events[_id].endTime) == 0, "NVT"); // Not valid time
        require(
            !events[_id].allPlayers[_eWallet],
            "user participate"
        );
        require(!events[_id].reverted, "reverted");
        require(!events[_id].eventFinish, "finished");

        if (events[_id].activePlayers == 0) {
            events[_id].reverted = true;
            emit revertedEvent(_id, "do not have players");
        } else {
            if (
                events[_id].calculateExperts && events[_id].amountExperts == 0
            ) {
                emit calculateExpert(_id, events[_id].activePlayers);
            } else {
                uint256 ae = events[_id].activeExperts;
                events[_id].expert[_answer][ae].expert = _eWallet;
                events[_id].expert[_answer][ae].reputation = _reput;
                events[_id].activeExperts = ae + 1;

                if (events[_id].activeExperts == events[_id].amountExperts && events[_id].amountExperts > 0) {
                    emit findCorrectAnswer(_id);
                }
            }
        }
    }

    function setActiveExpertsFromOracl(uint256 _amount, int256 _id) public ownerOnly {
        events[_id].amountExperts = _amount;
    }

}
