// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {PubStruct} from "../../struct/PubStruct.sol";
import {MPStruct} from "../../struct/MPStruct.sol";
import {Libs} from "./Libs.sol";
import {PPConfig} from "../../config/PPConfig.sol";
import {PublicEvents} from "./PublicEvents.sol";
 
contract PlayerPayment is Libs, PPConfig {
    event payToLosers(int id, uint avarageBet, uint calcMintedToken);
    event payToRefferers(int id);
    event eventFinish(int id);
    MPStruct mpData;
    PubStruct eventsData;
    PublicEvents PublicAddr;

    constructor(PublicEvents _addr, address _mpAddr) {
        PublicAddr = _addr;
        eventsData = PubStruct(_addr);
        mpData = MPStruct(_mpAddr);
    }

   function letsPayToPlayers(int _id) public {
        require(msg.sender == owner, "owner only");
        uint activePlay = eventsData.getActivePlayers(_id);
        uint rightPlay = eventsData.getPlayerAmount(_id, mpData.getCorrectAnswer(_id));
        uint winPool = getPercent(playersPers, mpData.getLoserPool(_id)) / rightPlay;
        uint premimWin = calcPremiumWin(_id, rightPlay);
        uint betAmount = 0;

        for ( uint i = 0; i < rightPlay; i++ ) {
            betAmount += eventsData.getPlayerTokens(_id, mpData.getCorrectAnswer(_id), i);
        }

        uint avarageBet = betAmount / activePlay;
        uint avarageBetWin = betAmount / rightPlay;
        uint calcMintedToken = getPercent(playersPersMint, mpData.getLoserPool(_id));
        payToPlay(_id, rightPlay, avarageBet, calcMintedToken, activePlay, avarageBetWin, winPool, premimWin);
    }

    function payToPlay(int _id, uint rightPlay, uint avarageBet, uint calcMintedToken, uint activePlay, uint avarageBetWin, uint winPool, uint premimWin) private {
       for ( uint i = 0; i < rightPlay; i++ ) {
            // mint token to users
            uint userBet = eventsData.getPlayerTokens(_id, mpData.getCorrectAnswer(_id), i);
            address payable userWallet = eventsData.getPlayerWallet(_id, mpData.getCorrectAnswer(_id), i);
            require(
                PublicAddr.mint(userWallet, (userBet / avarageBet) * (calcMintedToken / activePlay)),
                "mint to play"
            );
            // pay tokens to users
            require(
                PublicAddr.pay(userWallet, ((userBet / avarageBetWin) * winPool) + userBet),
                "pay to play"
            );
            if (eventsData.getPremiumAmount(_id) > 0) {
                // pay premium tokens to user
                require(
                    PublicAddr.payBTY(userWallet, (userBet / avarageBetWin) * premimWin),
                    "prem pay yo play"
                );
            }
        }
        emit payToLosers(_id, avarageBet, calcMintedToken);
    }

    function calcPremiumWin(int _id, uint rightPlay) private view returns(uint){
        if (eventsData.getPremiumAmount(_id) > 0) {
            uint premiumToken = getPercent(playersPersPremiun, eventsData.getPremiumAmount(_id));
            return premiumToken / rightPlay;
        }else{
            return 0;
        }
    }

    function letsPayToLoosers(
        int _id,
        uint _avarageBet,
        uint _calcMintedToken
    ) public {
        require(msg.sender == owner, "owner only");
        for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
            if (mpData.getCorrectAnswer(_id) != i && eventsData.getPlayerAmount(_id, i) != 0) {
                for (uint z = 0; z < eventsData.getPlayerAmount(_id, i); z++) {
                    uint mintLost = (eventsData.getPlayerTokens(_id, i, z) / _avarageBet) * (_calcMintedToken / eventsData.getActivePlayers(_id));
                    require(PublicAddr.mint(eventsData.getPlayerWallet(_id, i, z), mintLost), "pay to losers");
                }
            }
        }
       emit payToRefferers(_id);
    }

    function payToReff(int _id) private {
        // TODO
        mpData.setFinishEvent(_id);
        emit eventFinish(
            _id
        );
    }
}    