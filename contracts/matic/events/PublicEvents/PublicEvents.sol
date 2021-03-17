// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {TimeValidation} from "../../helpers/TimeValidation.sol";
import {BET} from "../../tokens/BET.sol";
import {BTY} from "../../tokens/BTY.sol";
import {PubStruct} from "../../struct/PubStruct.sol";
import {MPStruct} from "../../struct/MPStruct.sol";
import {MiddlePayment} from "./MiddlePayment.sol";

contract PublicEvents is
    TimeValidation,
    PubStruct
{
    event calculateExpert(int256 id, uint256 activePlayers);
    event findCorrectAnswer(int256 id);
    event revertedEvent(int256 id, string purpose);

    uint minBet = 10000000000000000;
    BET public betToken;
    BTY public btyToken;
    MPStruct mpData;
    MiddlePayment mpContract;
    address owner;
    address MPContract;
    address PPContract;
    
    constructor(BET _betAddress, BTY _btyAddress){
        betToken = _betAddress;
        btyToken = _btyAddress;
        owner = msg.sender;
    }

    function setAddresses(address _mpaddr, address _ppaddr) public {
        require( msg.sender == owner, "owner only");
        mpData = MPStruct(_mpaddr);
        mpContract = MiddlePayment(_mpaddr);
        MPContract = _mpaddr;
        PPContract = _ppaddr;
    }

    function newEvent(
        int _id,
        uint _sT,
        uint _eT,
        uint _questAmount,
        uint _amountExp,
        bool _calcExp,
        address payable _host,
        uint _amountPrem
    ) public payable {
        require( msg.sender == owner, "owner only");
        events[_id].id = _id;
        events[_id].startTime = _sT;
        events[_id].endTime = _eT;
        events[_id].questAmount = _questAmount;
        events[_id].amountExperts = _amountExp;
        events[_id].host = _host;
        events[_id].calculateExperts = _calcExp;
        if (_amountPrem > 0) {
            events[_id].premiumAmount = _amountPrem;
            require( btyToken.allowance(_host, address(this)) >= _amountPrem, "Allowance" );
            require( btyToken.transferFrom(_host, address(this), _amountPrem), "BTY PRO event" );
        }
    }

    function addAdvisor(address payable _advisor, int256 _id) public{
        require( msg.sender == owner, "owner only");
        events[_id].advisor = _advisor;
    }

    function setAnswer(
        int _id,
        uint _answer,
        uint _amount,
        address payable _pWallet
    ) public payable {
        require( msg.sender == owner, "owner only");
         require(
             timeAnswer(events[_id].startTime, events[_id].endTime) == 0,
             "Time is not valid"
         );
         require(mpData.checkReverted(_id) != true, "event is reverted");
         require(mpData.checkEventFinish(_id) != true, "event is finish");
         require(
             events[_id].allPlayers[_pWallet] != true,
             "user already participate in event"
         );
         require(_amount >= minBet, "bet amount must be bigger or equal to 0.01 tokens" );

        PubStruct.Player memory player;
        player = PubStruct.Player(_pWallet, _amount);
        events[_id].players[_answer].push(player);
        events[_id].allPlayers[_pWallet] = true;
        events[_id].activePlayers += 1;
        events[_id].pool += _amount;

         require(
             betToken.allowance(_pWallet, address(this)) >= _amount,
             "Allowance error"
         );
         require(
             betToken.transferFrom(_pWallet, address(this), _amount),
             "Transfer BET from players error"
         );
    }

    function setValidator(
        int _id,
        uint _answer,
        address payable _eWallet,
        int _reput
    ) public payable {
        require( msg.sender == owner, "owner only");
        require(timeValidate(events[_id].endTime) == 0, "not valid time"); 
        require(
            !events[_id].allPlayers[_eWallet],
            "user participate"
        );
        require(mpData.checkReverted(_id) != true, "event is reverted");
        require(mpData.checkEventFinish(_id) != true, "event is finish");

        if (events[_id].activePlayers <= 1) {
            mpData.setReverted(_id);
            if(events[_id].activePlayers == 0){
                emit revertedEvent(_id, "do not have players");
            }else{
                mpContract.revertedPayment(_id, "only one player on event");
            }
        } else {
            if (
                events[_id].calculateExperts && events[_id].amountExperts == 0
            ) {
                emit calculateExpert(_id, events[_id].activePlayers);
            } else {
                PubStruct.Expert memory expert;
                expert = PubStruct.Expert(_eWallet, _reput);
                events[_id].expert[_answer].push(expert);
                events[_id].activeExperts += 1;

                if (events[_id].activeExperts == events[_id].amountExperts && events[_id].amountExperts > 0) {
                    emit findCorrectAnswer(_id);
                }
            }
        }
    }

    function setActiveExpertsFromOracl(uint _amount, int _id) public {
        require( msg.sender == owner, "owner only");
        events[_id].amountExperts = _amount;
    }

    function mint(address _addr, uint _amount) public returns(bool) {
        require( msg.sender == MPContract || msg.sender == PPContract, "owner only");
        require(betToken.mintFromPublicContract(_addr, _amount),"pay err");
        return true;
    }

    function pay(address _addr, uint _amount) public returns(bool) {
        require( msg.sender == MPContract || msg.sender == PPContract, "owner only");
        require(betToken.transfer(_addr, _amount),"mint err");
        return true;
    }

    function payBTY(address _addr, uint _amount) public returns(bool) {
        require( msg.sender == MPContract || msg.sender == PPContract, "owner only");
        require(btyToken.transfer(_addr, _amount),"mint err");
        return true;
    }

}
