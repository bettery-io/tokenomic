// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Libs {
    function getPersent(uint256 _percent, uint256 _from)
        public
        pure
        returns (uint256)
    {
        return (_from * _percent) / 100;
    }

}
