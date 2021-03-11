// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {PubStruct} from "../../struct/PubStruct.sol";
import {EFStruct} from "../../struct/EFStruct.sol";
import {Libs} from "./Libs.sol";
import {ConfigVariables} from "../../config/ConfigVariables.sol";
import {BET} from "../../tokens/BET.sol";
import {BTY} from "../../tokens/BTY.sol";

contract FinishEvent is Libs, ConfigVariables, EFStruct {
    BET public betToken;
    BTY public btyToken;
    PubStruct eventsData;

    event payToCompanies(int id, uint tokens);
    event payToExperts(int id);
    event payToPlayers(int id);
    event payToLosers(int id, uint avarageBet, uint mintedTokens);
    event revertedEvent(int id, string purpose);
    event eventFinish(int id, uint tokens, uint correctAnswer);

    constructor(BET _betAddress, BTY _btyAddress, address _addr) {
        betToken = _betAddress;
        btyToken = _btyAddress;
        eventsData = PubStruct(_addr);
    }

    function letsFindCorrectAnswer(int _id) public ownerOnly() {
        uint bigValue = 0;
        uint candDub = 0;
        uint correctAnswer;
        uint questAmount = eventsData.getQuestAmount(_id);

        // find correct answer
        for (uint i = 0; i < questAmount; i++) {
            if (eventsData.getExpertAmount(_id, i) > bigValue) {
                bigValue = eventsData.getExpertAmount(_id, i);
                correctAnswer = i;
            } else if (eventsData.getExpertAmount(_id, i) == bigValue) {
                candDub = eventsData.getExpertAmount(_id, i);
            }
        }

        if (candDub == bigValue) {
            eventFinishData[_id].reverted = true;
            revertPayment(_id, "duplicat expert");
        } else {
            eventFinishData[_id].correctAnswer = correctAnswer;
            findLosersPool(correctAnswer, _id);
        }
    }

    function findLosersPool(uint correctAnswer, int _id) private {
        uint B;
        for (uint i = 0; i < eventsData.getPlayerAmount(_id, correctAnswer); i++) {
            B = B + eventsData.getPlayerTokens(_id, correctAnswer, i);
        }
        uint lP = eventsData.getPool(_id) - B;
        if (lP == 0) {
            revertedPayment(_id, "play chose one answer");
        } else {
            eventFinishData[_id].loserPool = lP;
            // calculate minted tokens
            uint tokens =
                calcMintedTokens(
                    eventsData.getActivePlayers(_id),
                    eventsData.getPool(_id),
                    GFindex
                );
            eventFinishData[_id].tokenMinted = tokens;
            emit payToCompanies(_id, tokens);
        }
    }

    function revertedPayment(int _id, string memory purpose)
        public
        ownerOnly()
    {
        revertPayment(_id, purpose);
    }

    function revertPayment(int _id, string memory purpose) private {
        for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
            for (uint z = 0; z < eventsData.getPlayerAmount(_id, i); z++) {
                require(
                    betToken.transfer(
                        eventsData.getPlayerWallet(_id, i, z),
                        eventsData.getPlayerTokens(_id, i, z)
                    ),
                    "Revert BET"
                );
            }
        }
        eventFinishData[_id].reverted = true;
        emit revertedEvent(_id, purpose);
    }

    // function letsPayToCompanies(int _id) public ownerOnly() {
    //     // pay to Development Fund
    //     require(
    //         betToken.mintFromPublicContract(
    //             owner,
    //             getPercent(additionalData[_id].tokenMinted, developFundPerc)
    //         ),
    //         "M DF"
    //     );
    //     if (additionalData[_id].premium) {
    //         require(
    //             btyToken.transfer(
    //                 owner,
    //                 getPercent(
    //                     additionalData[_id].amountPremiumEvent,
    //                     developFundPercPremim
    //                 )
    //             ),
    //             "Pre p DF"
    //         );
    //     }
    //     // pay to Community Marketing Fund
    //     uint percentCMF =
    //         events[_id].advisor != address(0)
    //             ? comMarketFundPerc
    //             : comMarketFundPerc + extraHostPercMint + advisorPercMint;
    //     require(
    //         betToken.mintFromPublicContract(
    //             comMarketFundWallet,
    //             getPercent(additionalData[_id].tokenMinted, percentCMF)
    //         ),
    //         "M CMF"
    //     );

    //     // pay to Moderators Fund
    //     require(
    //         betToken.mintFromPublicContract(
    //             moderatorsFundWallet,
    //             getPercent(additionalData[_id].tokenMinted, moderatorsFundPerc)
    //         ),
    //         "M MF"
    //     );
    //     letsPaytoHost(_id);
    // }

    // function letsPaytoHost(int _id) private {
    //     if (events[_id].advisor != address(0)) {
    //         // pay minted tokens
    //         require(
    //             betToken.mintFromPublicContract(
    //                 events[_id].host,
    //                 getPercent(
    //                     additionalData[_id].tokenMinted,
    //                     hostPercMint + extraHostPercMint
    //                 )
    //             ),
    //             "M Host with adv"
    //         );
    //         require(
    //             betToken.mintFromPublicContract(
    //                 events[_id].advisor,
    //                 getPercent(additionalData[_id].tokenMinted, advisorPercMint)
    //             ),
    //             "M to Adv"
    //         );
    //         // pay not minted tokens
    //         require(
    //             betToken.transfer(
    //                 events[_id].host,
    //                 getPercent(additionalData[_id].pool, hostPerc + extraHostPerc)
    //             ),
    //             "P Host with adv"
    //         );
    //         require(
    //             betToken.transfer(
    //                 events[_id].advisor,
    //                 getPercent(additionalData[_id].pool, advisorPepc)
    //             ),
    //             "P Adv"
    //         );
    //     } else {
    //         // pay minted tokens
    //         require(
    //             betToken.mintFromPublicContract(
    //                 events[_id].host,
    //                 getPercent(additionalData[_id].tokenMinted, hostPercMint)
    //             ),
    //             "M Host"
    //         );
    //         // pay not minted tokens
    //         require(
    //             betToken.transfer(
    //                 events[_id].host,
    //                 getPercent(additionalData[_id].pool, hostPerc)
    //             ),
    //             "P Host"
    //         );
    //     }
    //     emit payToExperts(_id);
    // }

    // function letsPayToExperts(int _id) public ownerOnly() {
    //     int allReputation;
    //     uint percent =
    //         events[_id].advisor != address(0)
    //             ? expertPerc
    //             : expertPerc + expertExtraPerc;

    //     for ( uint i = 0; i < events[_id].expert[additionalData[_id].correctAnswer].length; i++ ) {
    //         if ( events[_id].expert[additionalData[_id].correctAnswer][i].reputation >= 0 ) {
    //             allReputation = allReputation + events[_id].expert[additionalData[_id].correctAnswer][i].reputation;
    //         }
    //     }

    //     for (uint i = 0; i < events[_id].expert[additionalData[_id].correctAnswer].length; i++ ) {
    //         int reputation = events[_id].expert[additionalData[_id].correctAnswer][i].reputation;
    //         address payable expertWallet = events[_id].expert[additionalData[_id].correctAnswer][i].expert;
    //         if (reputation >= 0) {
    //             // mint tokens
    //             uint amountMint = (getPercent(additionalData[_id].tokenMinted, expertPercMint) * uint(reputation)) / uint(allReputation);
    //             require(
    //                 betToken.mintFromPublicContract(expertWallet, amountMint),
    //                 "M Exp"
    //             );
    //             // pay tokens
    //             uint amount = (getPercent(additionalData[_id].pool, percent) * uint(reputation)) / uint(allReputation);
    //             require(
    //                 betToken.transfer(expertWallet, amount),
    //                 "P Exp"
    //             );
    //             // pay in premium events
    //             if (additionalData[_id].premium) {
    //                 uint premiumAmount = (getPercent( additionalData[_id].amountPremiumEvent, expertPremiumPerc ) * uint(reputation)) / uint(allReputation);
    //                 require(
    //                     btyToken.transfer(expertWallet, premiumAmount),
    //                     "Prem p Exp"
    //                 );
    //             }
    //         }
    //     }
    //     emit payToPlayers(_id);
    // }

    // function letsPayToPlayers(int _id) public ownerOnly() {
    //     uint mintedTokens = getPercent(playersPersMint, additionalData[_id].tokenMinted);
    //     uint loserPoolPerc = getPercent(playersPers, additionalData[_id].loserPool);
    //     uint winPool = loserPoolPerc / events[_id].activePlayers;

    //     uint premimWin;
    //     if (additionalData[_id].premium) {
    //         uint premiumToken = getPercent(playersPersPremiun, additionalData[_id].amountPremiumEvent);
    //         premimWin = premiumToken / events[_id].activePlayers;
    //     }
    //     uint betAmount = 0;

    //     for ( uint i = 0; i < events[_id].players[additionalData[_id].correctAnswer].length; i++ ) {
    //         betAmount = betAmount + events[_id].players[additionalData[_id].correctAnswer][i].amount;
    //     }

    //     uint avarageBet = betAmount / events[_id].activePlayers;

    //     for ( uint i = 0; i < events[_id].players[additionalData[_id].correctAnswer].length; i++ ) {
    //         // mint token to users
    //         uint userBet = events[_id].players[additionalData[_id].correctAnswer][i].amount;
    //         address payable userWallet = events[_id].players[additionalData[_id].correctAnswer][i].player;
    //         uint mintWin = (userBet / avarageBet) * (mintedTokens / events[_id].activePlayers);
    //         // TODO pay to referers
    //         require(
    //             betToken.mintFromPublicContract(userWallet, mintWin),
    //             "M Play"
    //         );

    //         // pay tokens to users
    //         uint tokenWin = (userBet / avarageBet) * winPool;
    //         require(
    //             betToken.transfer(userWallet, tokenWin),
    //             "P Play"
    //         );
    //         if (additionalData[_id].premium) {
    //             // pay premium tokens to user
    //             uint premiumWinToken = (userBet / avarageBet) * premimWin;
    //             require(
    //                 btyToken.transfer(userWallet, premiumWinToken),
    //                 "Prem p Play"
    //             );
    //         }
    //     }
    //     emit payToLosers(_id, avarageBet, mintedTokens);
    // }

    // function letsPayToLoosers(
    //     int _id,
    //     uint _avarageBet,
    //     uint _mintedTokens
    // ) public ownerOnly() {
    //     for (uint i = 0; i < events[_id].questAmount; i++) {
    //         if (additionalData[_id].correctAnswer != i && events[_id].players[i].length != 0) {
    //             for (uint z = 0; z < events[_id].players[i].length; z++) {
    //                 uint mintLost = (events[_id].players[i][z].amount / _avarageBet) * (_mintedTokens / events[_id].activePlayers);
    //                 require(betToken.mintFromPublicContract(events[_id].players[i][z].player, mintLost), "P losers");
    //             }
    //         }
    //     }
    //     additionalData[_id].eventFinish = true;
    //     emit eventFinish(
    //         _id,
    //         additionalData[_id].tokenMinted,
    //         additionalData[_id].correctAnswer
    //     );
    // }
}
