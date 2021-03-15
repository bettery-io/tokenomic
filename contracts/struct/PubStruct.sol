// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PubStruct {
    struct Player {
        address payable player;
        uint amount;
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
        uint premiumAmount; 
    }

    mapping(int => EventData) public events;

    function getQuestAmount(int _id) view public returns(uint) {
        return events[_id].questAmount;
    }

    function getExpertAmount(int _id, uint i) view public returns(uint) {
        return events[_id].expert[i].length;
    }

    function getExpertWallet(int _id, uint i, uint z) view public returns(address payable) {
        return events[_id].expert[i][z].expert;
    }

    function getExpertReput(int _id, uint i, uint z) view public returns(int) {
        return events[_id].expert[i][z].reputation;
    }

    function getPlayerAmount(int _id, uint i) view public returns(uint) {
        return events[_id].players[i].length;
    }

    function getPlayerWallet(int _id, uint i, uint z) view public returns(address payable) {
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

    function getPremiumAmount(int _id) view public returns(uint) {
        return events[_id].premiumAmount;
    }

    function getAdvisorAddr(int _id) view public returns(address) {
        return events[_id].advisor;
    }

    function getHostAddr(int _id) view public returns(address) {
        return events[_id].host;
    }
}
