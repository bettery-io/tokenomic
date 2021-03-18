// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {PubStruct} from "../../struct/PubStruct.sol";

contract Libs {
    function getPercent(uint _percent, uint _from)
        public
        pure
        returns (uint)
    {
        return (_percent * _from) / 100;
    }

    function calcPercent(uint number, uint from) private pure returns (uint){
        return number * 100 / from; 
    }

    function calcMintedTokens(
        uint _GFindex,
        int _id,
        PubStruct eventsData
    ) public view returns (uint) {
        uint bigValue = 0; 
        uint bigValue2 = 0;

        for (uint i = 0; i < eventsData.getQuestAmount(_id); i++) {
            if (eventsData.getPlayerAmount(_id, i) > bigValue) {
                bigValue2 = bigValue;
                bigValue = eventsData.getPlayerAmount(_id, i);
            } else if (eventsData.getPlayerAmount(_id, i) > bigValue2) {
                bigValue2 = bigValue;
            }
        }
        uint activPlay =  eventsData.getActivePlayers(_id);
        uint controversy = (100 - calcPercent(bigValue, activPlay) + calcPercent(bigValue2, activPlay));
        uint averageBet = eventsData.getPool(_id) / activPlay; 
        return (averageBet * activPlay * controversy * _GFindex) / 10000;
    }
}
