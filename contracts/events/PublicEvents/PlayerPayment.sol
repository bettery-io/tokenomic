// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {PubStruct} from "../../struct/PubStruct.sol";
import {MPStruct} from "../../struct/MPStruct.sol";
import {Libs} from "./Libs.sol";
import {ConfigVariables} from "../../config/ConfigVariables.sol";
import {PublicEvents} from "./PublicEvents.sol";
 
contract PlayerPayment {
    event payToLosers(int id, uint avarageBet, uint mintedTokens);
    event eventFinish(int id, uint tokens, uint correctAnswer);
    PubStruct eventsData;
    PublicEvents PublicAddr;

    constructor(PublicEvents _addr) {
        PublicAddr = _addr;
        eventsData = PubStruct(_addr);
    }

   // function letsPayToPlayers(int _id) public ownerOnly() {
    //     uint activePlay = eventsData.getActivePlayers(_id);
    //     uint winPool = getPercent(playersPers, MPData[_id].loserPool) / activePlay;
    //     uint rightPlay = eventsData.getPlayerAmount(_id, MPData[_id].correctAnswer);

    //     uint premimWin;
    //     if (eventsData.getPremiumAmount(_id) > 0) {
    //         uint premiumToken = getPercent(playersPersPremiun, eventsData.getPremiumAmount(_id));
    //         premimWin = premiumToken / activePlay;
    //     }
    //     uint betAmount = 0;

    //     for ( uint i = 0; i < rightPlay; i++ ) {
    //         betAmount = betAmount + eventsData.getPlayerTokens(_id, MPData[_id].correctAnswer, i);
    //     }

    //     uint avarageBet = betAmount / activePlay;

    //     for ( uint i = 0; i < rightPlay; i++ ) {
    //         // mint token to users
    //         uint userBet = eventsData.getPlayerTokens(_id, MPData[_id].correctAnswer, i);
    //         address payable userWallet = eventsData.getPlayerWallet(_id, MPData[_id].correctAnswer, i);
    //         uint mintWin = (userBet / avarageBet) * (getPercent(playersPersMint, MPData[_id].tokenMinted) / activePlay);
    //         // TODO pay to referers
    //         require(
    //             betToken.mintFromPublicContract(userWallet, mintWin),
    //             "mint to play"
    //         );

    //         // pay tokens to users
    //         require(
    //             betToken.transfer(userWallet, (userBet / avarageBet) * winPool),
    //             "pay to play"
    //         );
    //         if (eventsData.getPremiumAmount(_id) > 0) {
    //             // pay premium tokens to user
    //             require(
    //                 btyToken.transfer(userWallet, (userBet / avarageBet) * premimWin),
    //                 "prem pay yo play"
    //             );
    //         }
    //     }
    //     emit payToLosers(_id, avarageBet, getPercent(playersPersMint, MPData[_id].tokenMinted));
    // }

    // function letsPayToLoosers(
    //     int _id,
    //     uint _avarageBet,
    //     uint _mintedTokens
    // ) public ownerOnly() {
    //     for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
    //         if (MPData[_id].correctAnswer != i && eventsData.getPlayerAmount(_id, i) != 0) {
    //             for (uint z = 0; z < eventsData.getPlayerAmount(_id, i); z++) {
    //                 uint mintLost = (eventsData.getPlayerTokens(_id, i, z) / _avarageBet) * (_mintedTokens / eventsData.getActivePlayers(_id));
    //                 require(betToken.mintFromPublicContract(eventsData.getPlayerWallet(_id, i, z), mintLost), "pay to losers");
    //             }
    //         }
    //     }
    //     MPData[_id].eventFinish = true;
    //     emit eventFinish(
    //         _id,
    //         MPData[_id].tokenMinted,
    //         MPData[_id].correctAnswer
    //     );
    // }
}    