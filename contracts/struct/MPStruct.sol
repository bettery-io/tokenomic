// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MPStruct {
    address ownerAddr;
    address MPContract;
    address PPContract;

    constructor() {
        ownerAddr = msg.sender;
    }

    struct MiddlePaymentStruct {
        int256 id;
        uint256 correctAnswer;
        uint256 loserPool;
        uint256 tokenMinted;
        bool reverted;
        bool eventFinish;
    }

    mapping(int256 => MiddlePaymentStruct) public MPData;

    function setAddresses(address _ppaddr) public {
        require(msg.sender == ownerAddr, "owner only");
        PPContract = _ppaddr;
    }

    function checkReverted(int256 _id) public view returns (bool) {
        return MPData[_id].reverted;
    }

    function checkEventFinish(int256 _id) public view returns (bool) {
        return MPData[_id].eventFinish;
    }

    function setReverted(int256 _id) public {
        require(msg.sender == PPContract, "ppContract only");
        MPData[_id].reverted = true;
    }

    function setFinishEvent(int256 _id) public {
        require(msg.sender == PPContract, "ppContract only");
        MPData[_id].eventFinish = true;
    }

    function getCorrectAnswer(int256 _id) public view returns (uint256) {
        return MPData[_id].correctAnswer;
    }

    function getTokenMinted(int256 _id) public view returns (uint256) {
        return MPData[_id].tokenMinted;
    }

    function getLoserPool(int256 _id) public view returns (uint256) {
        return MPData[_id].loserPool;
    }
}
