// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library PubStruct {
    struct Participant {
        address payable participants;
        uint256 amount;
    }

    struct Validator {
        address payable validators;
    }

    struct EventData {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint8 questionQuantity;
        uint256 pool;
        uint8 percentHost;
        uint8 percentValidator;
        mapping(uint256 => Participant[]) participant;
        mapping(uint256 => Validator[]) validator;
        uint256 validatorsAmount;
        bool expertsQuantityWay;
        uint256 activeValidators;
        address payable hostWallet;
        uint256 persentFeeCompany;
        uint256 persentFeeHost;
        uint256 persentForEachValidators;
        uint256 correctAnswer;
        address[] allParticipant;
        bool payEther;
        bool reverted;
    }
}
