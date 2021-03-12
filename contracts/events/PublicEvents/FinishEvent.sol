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
    event payToHost(int id);
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
                    "revert bet"
                );
            }
        }
        eventFinishData[_id].reverted = true;
        emit revertedEvent(_id, purpose);
    }

    function letsPayToCompanies(int _id) public ownerOnly() {
        // pay to Development Fund
        require(
            betToken.mintFromPublicContract(
                owner,
                getPercent(eventFinishData[_id].tokenMinted, developFundPerc)
            ),
            "mint development fund"
        );
        if (eventsData.getPremiumAmount(_id) > 0) {
            require(
                btyToken.transfer(
                    owner,
                    getPercent(
                        eventsData.getPremiumAmount(_id),
                        developFundPercPremim
                    )
                ),
                "premium pay development fund"
            );
        }
        // pay to Community Marketing Fund
        uint percentCMF =
            eventsData.getAdvisorAddr(_id) != address(0)
                ? comMarketFundPerc
                : comMarketFundPerc + extraHostPercMint + advisorPercMint;
        require(
            betToken.mintFromPublicContract(
                comMarketFundWallet,
                getPercent(eventFinishData[_id].tokenMinted, percentCMF)
            ),
            "mint community marketing fund"
        );

        // pay to Moderators Fund
        require(
            betToken.mintFromPublicContract(
                moderatorsFundWallet,
                getPercent(eventFinishData[_id].tokenMinted, moderatorsFundPerc)
            ),
            "mint moderators fund"
        );
        emit payToHost(_id);
    }

    function letsPaytoHost(int _id) public ownerOnly() {
        if (eventsData.getAdvisorAddr(_id) != address(0)) {
            // pay minted tokens
            require(
                betToken.mintFromPublicContract(
                    eventsData.getHostAddr(_id),
                    getPercent(
                        eventFinishData[_id].tokenMinted,
                        hostPercMint + extraHostPercMint
                    )
                ),
                "mint host with advisor"
            );
            require(
                betToken.mintFromPublicContract(
                    eventsData.getAdvisorAddr(_id),
                    getPercent(eventFinishData[_id].tokenMinted, advisorPercMint)
                ),
                "mint to advisor"
            );
            // pay not minted tokens
            require(
                betToken.transfer(
                    eventsData.getHostAddr(_id),
                    getPercent(eventsData.getPool(_id), hostPerc + extraHostPerc)
                ),
                "pay to host with advisor"
            );
            require(
                betToken.transfer(
                    eventsData.getAdvisorAddr(_id),
                    getPercent(eventsData.getPool(_id), advisorPepc)
                ),
                "pay to advisor"
            );
        } else {
            // pay minted tokens
            require(
                betToken.mintFromPublicContract(
                    eventsData.getHostAddr(_id),
                    getPercent(eventFinishData[_id].tokenMinted, hostPercMint)
                ),
                "mint to host"
            );
            // pay not minted tokens
            require(
                betToken.transfer(
                    eventsData.getHostAddr(_id),
                    getPercent(eventsData.getPool(_id), hostPerc)
                ),
                "pay to host"
            );
        }
        emit payToExperts(_id);
    }

    // function letsPayToExperts(int _id) public ownerOnly() {
    //     int allReputation;
    //     uint percent =
    //         eventsData.getAdvisorAddr(_id) != address(0)
    //             ? expertPerc
    //             : expertPerc + expertExtraPerc;
    //     uint correctAnswer = eventFinishData[_id].correctAnswer;
    //     for ( uint i = 0; i < eventsData.getExpertAmount(_id, correctAnswer); i++ ) {
    //         if ( eventsData.getExpertReput(_id, correctAnswer, i) >= 0 ) {
    //             allReputation = allReputation + eventsData.getExpertReput(_id, correctAnswer, i);
    //         }
    //     }

    //     for (uint i = 0; i < eventsData.getExpertAmount(_id, correctAnswer); i++ ) {
    //         int reputation = eventsData.getExpertReput(_id, correctAnswer, i);
    //         address payable expertWallet = eventsData.getExpertWallet(_id, correctAnswer, i);
    //         if (reputation >= 0) {
    //             // mint tokens
    //             uint amountMint = (getPercent(eventFinishData[_id].tokenMinted, expertPercMint) * uint(reputation)) / uint(allReputation);
    //             require(
    //                 betToken.mintFromPublicContract(expertWallet, amountMint),
    //                 "mint exp"
    //             );
    //             // pay tokens
    //             uint amount = (getPercent(eventsData.getPool(_id), percent) * uint(reputation)) / uint(allReputation);
    //             require(
    //                 betToken.transfer(expertWallet, amount),
    //                 "pay exp"
    //             );
    //             // pay in premium events
    //             if (eventsData.getPremiumAmount(_id) > 0) {
    //                 uint premiumAmount = (getPercent(eventsData.getPremiumAmount(_id), expertPremiumPerc ) * uint(reputation)) / uint(allReputation);
    //                 require(
    //                     btyToken.transfer(expertWallet, premiumAmount),
    //                     "prem pay exp"
    //                 );
    //             }
    //         }
    //     }
    //     emit payToPlayers(_id);
    // }

    // function letsPayToPlayers(int _id) public ownerOnly() {
    //     uint activePlay = eventsData.getActivePlayers(_id);
    //     uint winPool = getPercent(playersPers, eventFinishData[_id].loserPool) / activePlay;
    //     uint rightPlay = eventsData.getPlayerAmount(_id, eventFinishData[_id].correctAnswer);

    //     uint premimWin;
    //     if (eventsData.getPremiumAmount(_id) > 0) {
    //         uint premiumToken = getPercent(playersPersPremiun, eventsData.getPremiumAmount(_id));
    //         premimWin = premiumToken / activePlay;
    //     }
    //     uint betAmount = 0;

    //     for ( uint i = 0; i < rightPlay; i++ ) {
    //         betAmount = betAmount + eventsData.getPlayerTokens(_id, eventFinishData[_id].correctAnswer, i);
    //     }

    //     uint avarageBet = betAmount / activePlay;

    //     for ( uint i = 0; i < rightPlay; i++ ) {
    //         // mint token to users
    //         uint userBet = eventsData.getPlayerTokens(_id, eventFinishData[_id].correctAnswer, i);
    //         address payable userWallet = eventsData.getPlayerWallet(_id, eventFinishData[_id].correctAnswer, i);
    //         uint mintWin = (userBet / avarageBet) * (getPercent(playersPersMint, eventFinishData[_id].tokenMinted) / activePlay);
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
    //     emit payToLosers(_id, avarageBet, getPercent(playersPersMint, eventFinishData[_id].tokenMinted));
    // }

    // function letsPayToLoosers(
    //     int _id,
    //     uint _avarageBet,
    //     uint _mintedTokens
    // ) public ownerOnly() {
    //     for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
    //         if (eventFinishData[_id].correctAnswer != i && eventsData.getPlayerAmount(_id, i) != 0) {
    //             for (uint z = 0; z < eventsData.getPlayerAmount(_id, i); z++) {
    //                 uint mintLost = (eventsData.getPlayerTokens(_id, i, z) / _avarageBet) * (_mintedTokens / eventsData.getActivePlayers(_id));
    //                 require(betToken.mintFromPublicContract(eventsData.getPlayerWallet(_id, i, z), mintLost), "pay to losers");
    //             }
    //         }
    //     }
    //     eventFinishData[_id].eventFinish = true;
    //     emit eventFinish(
    //         _id,
    //         eventFinishData[_id].tokenMinted,
    //         eventFinishData[_id].correctAnswer
    //     );
    // }
}
