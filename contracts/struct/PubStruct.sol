// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PubStruct {
    struct Player {
        int playerId;
        address payable player;
        uint amount;
        uint referrersDeep;
    }

    struct Referrers {
        address payable[] referrer;
    }

    struct Expert {
        address payable expert;
        int reputation;
    }

    struct EventData {
        int id;
        uint startTime;
        uint endTime;
        uint questAmount;
        mapping(uint => Player[]) players;
        mapping(address => bool) allPlayers; // added for validation if players whant ot be expers
        uint activePlayers; // amount of all players
        mapping(uint => Expert[]) expert;
        uint activeExperts; // amount of all expers
        uint amountExperts; // expers needed for finish event, can be 0 if calculateExperts is true
        bool calculateExperts; 
        address payable host;
        address payable advisor;
        uint pool;
        uint amountPremiumEvent; 
    }

    mapping(int => EventData) public events;
    mapping(string => Referrers) referrers; // include eventID + userID + referrersDeep

    function getQuestAmount(int _id) view public returns(uint) {
        return events[_id].questAmount;
    }

    function getExpertAmount(int _id, uint i) view public returns(uint) {
        return events[_id].expert[i].length;
    }

    function getPlayerAmount(int _id, uint i) view public returns(uint) {
        return events[_id].players[i].length;
    }

    function getPlayerWallet(int _id, uint i, uint z) view public returns(address) {
        return events[_id].players[i][z].player;
    }

    function getPlayerTokens(int _id, uint i, uint z) view public returns(uint) {
        return events[_id].players[i][z].amount;
    }

    function getActivePlayers(int _id) view public returns(uint) {
        return events[_id].activePlayers;
    }

    function getPool(int _id) view public returns(uint) {
        return events[_id].pool;
    }
}
