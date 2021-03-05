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
    event revertedEvent(int256 id, string purpose);

    constructor(BET _betAddress, BTY _btyAddress) {
        betToken = _betAddress;
        btyToken = _btyAddress;
    }

    function letsFindCorrectAnswer(int256 _id) public {
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
            // calculate minted tokens
            uint256 controversy = (100 - events[_id].activePlayers) / 100;
            uint256 averageBet = events[_id].pool / events[_id].activePlayers;
            uint256 tokens =
                ((averageBet *
                    events[_id].activePlayers *
                    controversy *
                    GFindex) * 1000000000000000000) / 100;
            events[_id].tokenMinted = tokens;
            letsFinishEvent(_id, tokens);
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

    function letsFinishEvent(int256 _id, uint256 _tokens) public ownerOnly() {
        events[_id].tokenMinted = _tokens;
        // pay to Development Fund
        uint256 percentFee = getPersent(_tokens, developFundPerc);
        require(
            betToken.mintFromPublicContract(owner, percentFee),
            "Mint to Development Fund error"
        );
        if (events[_id].premium) {
            uint256 percentBTYFee =
                getPersent(
                    events[_id].amountPremiumEvent,
                    developFundPercPremim
                );
            require(
                btyToken.transfer(owner, percentBTYFee),
                "Pay premium tokens to Development Fund error"
            );
        }
        // pay to Community Marketing Fund
        uint256 percentCMF =
            events[_id].advisor != address(0)
                ? comMarketFundPerc
                : comMarketFundPerc + extraHostPercMint + advisorPercMint;
        uint256 calcPercCMF = getPersent(_tokens, percentCMF);
        require(
            betToken.mintFromPublicContract(comMarketFundWallet, calcPercCMF),
            "Mint to Community Marketing Fund error"
        );

        // pay to Moderators Fund
        uint256 percentFeeModerFund = getPersent(_tokens, moderatorsFundPerc);
        require(
            betToken.mintFromPublicContract(
                moderatorsFundWallet,
                percentFeeModerFund
            ),
            "Min to Moderators Fund"
        );
        paytoHost(_id);
    }

    function paytoHost(int256 _id) private {
        if (events[_id].advisor != address(0)) {
            // pay minted tokens
            uint256 percHostFeeMint =
                getPersent(
                    events[_id].tokenMinted,
                    hostPercMint + extraHostPercMint
                );
            require(
                betToken.mintFromPublicContract(
                    events[_id].host,
                    percHostFeeMint
                ),
                "Min to Host with advisor error"
            );
            uint256 percAdvisorFeeMint =
                getPersent(events[_id].tokenMinted, advisorPercMint);
            require(
                betToken.mintFromPublicContract(
                    events[_id].advisor,
                    percAdvisorFeeMint
                ),
                "Mint to Advisor error"
            );
            // pay not minted tokens
            uint256 percHostFee =
                getPersent(events[_id].pool, hostPerc + extraHostPerc);
            require(
                betToken.transfer(events[_id].host, percHostFee),
                "Pay to Host with advisor error"
            );
            uint256 percAdvisorFee = getPersent(events[_id].pool, advisorPepc);
            require(
                betToken.transfer(events[_id].advisor, percAdvisorFee),
                "Pay to Advisor error"
            );
        } else {
            // pay minted tokens
            uint256 percFeeMint =
                getPersent(events[_id].tokenMinted, hostPercMint);
            require(
                betToken.mintFromPublicContract(events[_id].host, percFeeMint),
                "Mint to Host error"
            );
            // pay not minted tokens
            uint256 percFee = getPersent(events[_id].pool, hostPerc);
            require(
                betToken.transfer(events[_id].host, percFee),
                "Pay to Host error"
            );
        }
        payToExperts(_id);
    }

    function payToExperts(int256 _id) private {
        uint256 correctAnswer = events[_id].correctAnswer;
        int256 allReputation;
        uint256 percent =
            events[_id].advisor != address(0)
                ? expertPerc
                : expertPerc + expertExtraPerc;

        for (uint8 i = 0; i < events[_id].expert[correctAnswer].length; i++) {
            int256 reputation = events[_id].expert[correctAnswer][i].reputation;
            if (reputation > 0) {
                allReputation = allReputation + reputation;
            }
        }

        for (uint8 i = 0; i < events[_id].expert[correctAnswer].length; i++) {
            int256 reputation = events[_id].expert[correctAnswer][i].reputation;
            address payable expertWallet = events[_id].expert[correctAnswer][i].expert;
            if (reputation > 0) {
                // mint tokens
                uint256 percFeeMint =
                    getPersent(events[_id].tokenMinted, expertPercMint);
                uint256 amountMint =
                    (percFeeMint * uint256(reputation)) /
                        uint256(allReputation);
                require(
                    betToken.mintFromPublicContract(expertWallet, amountMint),
                    "Mint to Experts error"
                );
                // pay tokens
                uint256 percFee = getPersent(events[_id].pool, percent);
                uint256 amount =
                    (percFee * uint256(reputation)) / uint256(allReputation);
                require(
                    betToken.transfer(expertWallet, amount),
                    "Pay to Experts error"
                );
                // pay in premium events
                if (events[_id].premium) {
                    uint256 percPremium =
                        getPersent(
                            events[_id].amountPremiumEvent,
                            expertPremiumPerc
                        );
                    uint256 premiumAmount =
                        (percPremium * uint256(reputation)) /
                            uint256(allReputation);
                    require(
                        btyToken.transfer(expertWallet, premiumAmount),
                        "Pay premium tokens to Experts error"
                    );
                }
            }
        }
        payToPlayers(_id);
    }

    function payToPlayers(int256 _id) private {
        // TODO
    }
}
