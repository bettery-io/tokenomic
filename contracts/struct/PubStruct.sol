// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PubStruct {
    struct Player {
        int256 playerId;
        address payable player;
        uint256 amount;
        uint8 referrersDeep;
    }

    struct Referrers {
        address payable[] referrer;
    }

    struct Expert {
        address payable expert;
        int256 reputation;
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
        address payable advisor;
        uint256 correctAnswer;
        uint256 pool;
        uint256 loserPool;
        uint256 tokenMinted;
        bool reverted; 
        bool premium; // if true amountProEvent can't be 0
        uint256 amountPremiumEvent; 
        bool eventFinish;
    }

    mapping(int256 => EventData) events;
    mapping(string => Referrers) referrers; // include eventID + userID + referrersDeep
}
