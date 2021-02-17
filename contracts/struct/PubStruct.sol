// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library PubStruct {
    struct Player {
        address payable player;
        uint256 amount;
    //    mapping(uint256 => Referrers[]) referals;
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
        mapping(address => bool) allPlayers; // added for validation if players whant ot be expers
        uint256 activePlayers; // amount of all players
        mapping(uint256 => Expert[]) expert;
        uint256 activeExperts; // amount of all expers
        uint256 amountExperts; // expers needed for finish event, can be 0 if calculateExperts is true
        bool calculateExperts; 
        address payable host;
        uint256 correctAnswer;
        uint256 pool;
        bool reverted; 
        bool premium; // if true amountProEvent can't be 0
        uint256 amountPremiumEvent; 
        bool eventFinish;
    }
}
