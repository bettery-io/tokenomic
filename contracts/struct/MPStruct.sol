// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MPStruct {
    struct MiddlePaymentStruct {
        int256 id;
        uint256 correctAnswer;
        uint256 loserPool;
        uint256 tokenMinted;
        bool reverted;
        bool eventFinish;
    }

    mapping(int256 => MiddlePaymentStruct) public MPData;

    function checkReverted(int256 _id) public view returns (bool) {
        return MPData[_id].reverted;
    }

    function checkEventFinish(int256 _id) public view returns (bool) {
        return MPData[_id].eventFinish;
    }

    function setReverted(int256 _id) public {
        MPData[_id].reverted = true;
    }
}
