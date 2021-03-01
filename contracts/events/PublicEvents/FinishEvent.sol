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
    event calculateTokensAmount(
        int256 id,
        uint256 activePlayers,
        uint256 pool,
        uint256 GFindex
    );

    constructor(BET _betAddress, BTY _btyAddress) {
        betToken = _betAddress;
        btyToken = _btyAddress;
    }

    function letsFindCorrectAnswer(int256 _id) public {
        uint256 biggestValue = 0;
        uint256 correctAnswer;

        // find correct answer
        for (uint8 i = 0; i < events[_id].questAmount; i++) {
            if (events[_id].expert[i].length > biggestValue) {
                biggestValue = events[_id].expert[i].length;
                correctAnswer = i;
            }
        }

        findDuplicates(
            correctAnswer,
            biggestValue,
            _id,
            events[_id].questAmount
        );
    }

    function findDuplicates(
        uint256 correctAnswer,
        uint256 biggestValue,
        int256 _id,
        uint8 questAmount
    ) private {
        if (events[_id].activeExperts > 1) {
            uint8 duplicatesAnswers = 0;
            uint256[] memory expertAnswers = new uint256[](questAmount);
            for (uint8 i = 0; i < questAmount; i++) {
                expertAnswers[i] = events[_id].expert[i].length;
            }

            setSort(expertAnswers);
            sort();

            for (uint8 i = 0; i < sortedArray.length - 1; i++) {
                if ((i + 1) < sortedArray.length) {
                    if (sortedArray[i + 1] == sortedArray[i]) {
                        if (biggestValue == sortedArray[i]) {
                            duplicatesAnswers++;
                        }
                    }
                }
            }

            if (duplicatesAnswers > 0) {
                events[_id].reverted = true;
                revertPayment(_id, "duplicates validators");
            } else {
                events[_id].correctAnswer = correctAnswer;
                findLosersPool(correctAnswer, _id);
            }
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
            emit calculateTokensAmount(
                _id,
                events[_id].activePlayers,
                events[_id].pool,
                GFindex
            );
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
        // pay for company
        uint256 persentFee = getPersent(_tokens, companyPerc);
        require(
            betToken.mintFromPublicContract(owner, persentFee),
            "Revert BET token to players is error"
        );
        paytoHost(_id);
    }

    function paytoHost(int256 _id) private {
        uint256 persentFee = getPersent(events[_id].tokenMinted, hostPerc);
        require(
            betToken.mintFromPublicContract(events[_id].host, persentFee),
            "Revert BET token to players is error"
        );
        payToExperts(_id);
    }

    function payToExperts(int256 _id) private {
        uint256 correctAnswer = events[_id].correctAnswer;
        uint256 allReputation;

        for (uint8 i = 0; i < events[_id].expert[correctAnswer].length; i++) {
            allReputation =
                allReputation +
                events[_id].expert[correctAnswer][i].reputation;
        }

        for (uint8 i = 0; i < events[_id].expert[correctAnswer].length; i++) {
            uint256 persentFee =
                getPersent(events[_id].tokenMinted, expertPerc);
            uint256 amount =
                (persentFee * events[_id].expert[correctAnswer][i].reputation) /
                    allReputation;
            require(
                betToken.mintFromPublicContract(
                    events[_id].expert[correctAnswer][i].expert,
                    amount
                ),
                "Revert BET token to players is error"
            );
        }
        payToPlayers(_id);
    }

    function payToPlayers(int256 _id) private {}
}
