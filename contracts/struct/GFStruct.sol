// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//TODO
library GFStruct {
    struct Player {
        address payable players;
    }

    struct EventData {
        int256 id;
        uint256 startTime;
        uint256 endTime;
        mapping(uint256 => Player[]) player;
    }
}