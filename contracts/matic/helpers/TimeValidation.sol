// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TimeValidation {
    function timeAnswer(uint256 _startTime, uint256 _endTime)
        public
        view
        returns (int8)
    {
        if (int256(block.timestamp - _startTime) >= 0) {
            if (int256(_endTime - block.timestamp) >= 0) {
                // user can make answer because time is valid.
                return 0;
            } else {
                // user can't make answer because event is finish.
                return 2;
            }
        } else {
            // user can't make answer because event is not started yet.
            return 1;
        }
    }

    function timeValidate(uint256 _endTime) public view returns (int8) {
        if (int256(block.timestamp - _endTime) >= 0) {
            // user can validate because time is valid.
            return 0;
        } else {
            // user can't validate because event is not started yet.
            return 1;
        }
    }
}
