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
                findLosersPool(_id);
            }
        } else {
            events[_id].correctAnswer = correctAnswer;
            findLosersPool(_id);
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

    function findLosersPool(int256 _id) private {}
}
