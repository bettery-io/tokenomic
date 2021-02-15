// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library PubStruct {
    struct Player {
        address payable player;
        uint256 amount;
        mapping(uint256 => Referrers[]) referals;
    }

    struct Referrers {
        address[] referal;
    }

    struct Expert {
        address payable expert;
        int256 rating; 
    }

    struct EventData {
        int256 id;
        uint256 startTime;
        uint256 endTime;
        uint8 questAmount;
        mapping(uint256 => Player[]) players;
        mapping(uint256 => Expert[]) expert;
        uint256 amountExperts;
        bool calculateExperts;
        uint256 activeExperts;
        address payable host;
        uint256 correctAnswer;
        address[] allPlayers;
        uint256 pool;
        bool reverted;
    }
}
