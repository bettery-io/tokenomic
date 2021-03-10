// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {PubStruct} from "../../struct/PubStruct.sol";
import {Libs} from "./Libs.sol";
import {ConfigVariables} from "../../config/ConfigVariables.sol";
import {BET} from "../../tokens/BET.sol";
import {BTY} from "../../tokens/BTY.sol";

abstract contract FinishEvent is PubStruct, Libs, ConfigVariables {
    BET public betToken;
    BTY public btyToken;

    event payToCompanies(int256 id, uint256 tokens);
    event paytoHost(int256 id);
    event payToExperts(int256 id);
    event payToPlayers(int256 id);
    event payToLosers(int256 id, uint256 avarageBet, uint256 mintedTokens);
    event revertedEvent(int256 id, string purpose);
    event eventFinish(int256 id, uint256 tokens, uint256 correctAnswer);

    constructor(BET _betAddress, BTY _btyAddress) {
        betToken = _betAddress;
        btyToken = _btyAddress;
    }

    function letsFindCorrectAnswer(int256 _id) public ownerOnly() {
        uint256 biggestValue = 0;
        uint256 candidateOfDublicates = 0;
        uint256 correctAnswer;

        // find correct answer
        for (uint8 i = 0; i < events[_id].questAmount; i++) {
            if (events[_id].expert[i].length > biggestValue) {
                biggestValue = events[_id].expert[i].length;
                correctAnswer = i;
            } else if (events[_id].expert[i].length == biggestValue) {
                candidateOfDublicates = events[_id].expert[i].length;
            }
        }

        if (candidateOfDublicates == biggestValue) {
            events[_id].reverted = true;
            revertPayment(_id, "duplicates validators");
        } else {
            events[_id].correctAnswer = correctAnswer;
            findLosersPool(correctAnswer, _id);
        }
    }

    function findLosersPool(uint256 correctAnswer, int256 _id) private {
        uint256 B;
        uint256 n = events[_id].players[correctAnswer].length;
        for (uint8 i = 0; i < n; i++) {
            B = B + events[_id].players[correctAnswer][i].amount;
        }
        uint256 loserPool = events[_id].pool - B;
        if (loserPool == 0) {
            revertedPayment(_id, "players chose only one answer");
        } else {
            events[_id].loserPool = loserPool;
            // calculate minted tokens
            uint256 tokens =
                calcMintedTokens(
                    events[_id].activePlayers,
                    events[_id].pool,
                    GFindex
                );
            events[_id].tokenMinted = tokens;
            emit payToCompanies(_id, tokens);
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

    function letsPayToCompanies(int256 _id) public ownerOnly() {
        uint256 tokens = events[_id].tokenMinted;
        // pay to Development Fund
        require(
            betToken.mintFromPublicContract(
                owner,
                getPercent(tokens, developFundPerc)
            ),
            "Mint to Development Fund error"
        );
        if (events[_id].premium) {
            require(
                btyToken.transfer(
                    owner,
                    getPercent(
                        events[_id].amountPremiumEvent,
                        developFundPercPremim
                    )
                ),
                "Pay premium tokens to Development Fund error"
            );
        }
        // pay to Community Marketing Fund
        uint256 percentCMF =
            events[_id].advisor != address(0)
                ? comMarketFundPerc
                : comMarketFundPerc + extraHostPercMint + advisorPercMint;
        require(
            betToken.mintFromPublicContract(
                comMarketFundWallet,
                getPercent(tokens, percentCMF)
            ),
            "Mint to Community Marketing Fund error"
        );

        // pay to Moderators Fund
        require(
            betToken.mintFromPublicContract(
                moderatorsFundWallet,
                getPercent(tokens, moderatorsFundPerc)
            ),
            "Min to Moderators Fund"
        );
        emit paytoHost(_id);
    }

    function letsPaytoHost(int256 _id) public ownerOnly() {
        if (events[_id].advisor != address(0)) {
            // pay minted tokens
            require(
                betToken.mintFromPublicContract(
                    events[_id].host,
                    getPercent(
                        events[_id].tokenMinted,
                        hostPercMint + extraHostPercMint
                    )
                ),
                "Min to Host with advisor error"
            );
            require(
                betToken.mintFromPublicContract(
                    events[_id].advisor,
                    getPercent(events[_id].tokenMinted, advisorPercMint)
                ),
                "Mint to Advisor error"
            );
            // pay not minted tokens
            require(
                betToken.transfer(
                    events[_id].host,
                    getPercent(events[_id].pool, hostPerc + extraHostPerc)
                ),
                "Pay to Host with advisor error"
            );
            require(
                betToken.transfer(
                    events[_id].advisor,
                    getPercent(events[_id].pool, advisorPepc)
                ),
                "Pay to Advisor error"
            );
        } else {
            // pay minted tokens
            require(
                betToken.mintFromPublicContract(
                    events[_id].host,
                    getPercent(events[_id].tokenMinted, hostPercMint)
                ),
                "Mint to Host error"
            );
            // pay not minted tokens
            require(
                betToken.transfer(
                    events[_id].host,
                    getPercent(events[_id].pool, hostPerc)
                ),
                "Pay to Host error"
            );
        }
        emit payToExperts(_id);
    }

    function letsPayToExperts(int256 _id) public ownerOnly() {
        int256 allReputation;
        uint256 percent =
            events[_id].advisor != address(0)
                ? expertPerc
                : expertPerc + expertExtraPerc;

        for ( uint8 i = 0; i < events[_id].expert[events[_id].correctAnswer].length; i++ ) {
            if ( events[_id].expert[events[_id].correctAnswer][i].reputation >= 0 ) {
                allReputation = allReputation + events[_id].expert[events[_id].correctAnswer][i].reputation;
            }
        }

        for (uint8 i = 0; i < events[_id].expert[events[_id].correctAnswer].length; i++ ) {
            int256 reputation = events[_id].expert[events[_id].correctAnswer][i].reputation;
            address payable expertWallet = events[_id].expert[events[_id].correctAnswer][i].expert;
            if (reputation >= 0) {
                // mint tokens
                uint256 amountMint = (getPercent(events[_id].tokenMinted, expertPercMint) * uint256(reputation)) / uint256(allReputation);
                require(
                    betToken.mintFromPublicContract(expertWallet, amountMint),
                    "Mint to Experts error"
                );
                // pay tokens
                uint256 amount = (getPercent(events[_id].pool, percent) * uint256(reputation)) / uint256(allReputation);
                require(
                    betToken.transfer(expertWallet, amount),
                    "Pay to Experts error"
                );
                // pay in premium events
                if (events[_id].premium) {
                    uint256 premiumAmount = (getPercent( events[_id].amountPremiumEvent, expertPremiumPerc ) * uint256(reputation)) / uint256(allReputation);
                    require(
                        btyToken.transfer(expertWallet, premiumAmount),
                        "Pay premium tokens to Experts error"
                    );
                }
            }
        }
        emit payToPlayers(_id);
    }

    function letsPayToPlayers(int256 _id) public ownerOnly() {
        uint256 mintedTokens = getPercent(playersPersMint, events[_id].tokenMinted);
        uint256 loserPoolPerc = getPercent(playersPers, events[_id].loserPool);
        uint256 winPool = loserPoolPerc / events[_id].activePlayers;

        uint256 premimWin;
        if (events[_id].premium) {
            uint256 premiumToken = getPercent(playersPersPremiun, events[_id].amountPremiumEvent);
            premimWin = premiumToken / events[_id].activePlayers;
        }
        uint256 betAmount = 0;

        for ( uint8 i = 0; i < events[_id].players[events[_id].correctAnswer].length; i++ ) {
            betAmount = betAmount + events[_id].players[events[_id].correctAnswer][i].amount;
        }

        uint256 avarageBet = betAmount / events[_id].activePlayers;

        for ( uint8 i = 0; i < events[_id].players[events[_id].correctAnswer].length; i++ ) {
            // mint token to users
            uint256 userBet = events[_id].players[events[_id].correctAnswer][i].amount;
            address payable userWallet = events[_id].players[events[_id].correctAnswer][i].player;
            uint256 mintWin = (userBet / avarageBet) * (mintedTokens / events[_id].activePlayers);
            // TODO pay to referers
            require(
                betToken.mintFromPublicContract(userWallet, mintWin),
                "Mint to Players error"
            );

            // pay tokens to users
            uint256 tokenWin = (userBet / avarageBet) * winPool;
            require(
                betToken.transfer(userWallet, tokenWin),
                "Pay to Players error"
            );
            if (events[_id].premium) {
                // pay premium tokens to user
                uint256 premiumWinToken = (userBet / avarageBet) * premimWin;
                require(
                    btyToken.transfer(userWallet, premiumWinToken),
                    "Premium pay to Players error"
                );
            }
        }

        emit payToLosers(_id, avarageBet, mintedTokens);
    }

    function letsPayToLoosers(
        int256 _id,
        uint256 _avarageBet,
        uint256 _mintedTokens
    ) public ownerOnly() {
        for (uint8 i = 0; i < events[_id].questAmount; i++) {
            if (events[_id].correctAnswer != i && events[_id].players[i].length != 0) {
                for (uint8 z = 0; z < events[_id].players[i].length; z++) {
                    uint256 mintLost = (events[_id].players[i][z].amount / _avarageBet) * (_mintedTokens / events[_id].activePlayers);
                    require(betToken.mintFromPublicContract(events[_id].players[i][z].player, mintLost), "Pay to losers error");
                }
            }
        }
        events[_id].eventFinish = true;
        emit eventFinish(
            _id,
            events[_id].tokenMinted,
            events[_id].correctAnswer
        );
    }
}
