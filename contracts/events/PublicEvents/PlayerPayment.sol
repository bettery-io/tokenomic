// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {PubStruct} from "../../struct/PubStruct.sol";
import {MPStruct} from "../../struct/MPStruct.sol";
import {Libs} from "./Libs.sol";
import {PPConfig} from "../../config/PPConfig.sol";
import {PublicEvents} from "./PublicEvents.sol";
 
contract PlayerPayment is Libs, PPConfig {
    event payToLosers(int id, uint avarageBet);
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
        uint winPool = getPercent(playersPers, mpData.getLoserPool(_id)) / activePlay;
        uint rightPlay = eventsData.getPlayerAmount(_id, mpData.getCorrectAnswer(_id));

        uint premimWin;
        if (eventsData.getPremiumAmount(_id) > 0) {
            uint premiumToken = getPercent(playersPersPremiun, eventsData.getPremiumAmount(_id));
            premimWin = premiumToken / activePlay;
        }
        uint betAmount = 0;

        for ( uint i = 0; i < rightPlay; i++ ) {
            betAmount = betAmount + eventsData.getPlayerTokens(_id, mpData.getCorrectAnswer(_id), i);
        }

        uint avarageBet = betAmount / activePlay;

        for ( uint i = 0; i < rightPlay; i++ ) {
            // mint token to users
            uint userBet = eventsData.getPlayerTokens(_id, mpData.getCorrectAnswer(_id), i);
            address payable userWallet = eventsData.getPlayerWallet(_id, mpData.getCorrectAnswer(_id), i);
            if(eventsData.getRefDeep(_id, mpData.getCorrectAnswer(_id), i) > 0){
                payToReff(_id);
            }else{
                uint mintWin = (userBet / avarageBet) * (getPercent(playersPersMint, mpData.getLoserPool(_id)) / activePlay);
                require(
                    PublicAddr.mint(userWallet, mintWin),
                    "mint to play"
                );
            }

            // pay tokens to users
            require(
                PublicAddr.pay(userWallet, (userBet / avarageBet) * winPool),
                "pay to play"
            );
            if (eventsData.getPremiumAmount(_id) > 0) {
                // pay premium tokens to user
                require(
                    PublicAddr.payBTY(userWallet, (userBet / avarageBet) * premimWin),
                    "prem pay yo play"
                );
            }
        }
        emit payToLosers(_id, avarageBet);
    }

    function payToReff(int _id) private {
        // TODO
    }

    function letsPayToLoosers(
        int _id,
        uint _avarageBet
    ) public {
        require(msg.sender == owner, "owner only");
        uint mintedTokens = getPercent(playersPersMint, mpData.getTokenMinted(_id));
        for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
            if (mpData.getCorrectAnswer(_id) != i && eventsData.getPlayerAmount(_id, i) != 0) {
                for (uint z = 0; z < eventsData.getPlayerAmount(_id, i); z++) {
                    uint mintLost = (eventsData.getPlayerTokens(_id, i, z) / _avarageBet) * (mintedTokens / eventsData.getActivePlayers(_id));
                    require(PublicAddr.mint(eventsData.getPlayerWallet(_id, i, z), mintLost), "pay to losers");
                }
            }
        }
        mpData.setFinishEvent(_id);
        emit eventFinish(
            _id
        );
    }
}    