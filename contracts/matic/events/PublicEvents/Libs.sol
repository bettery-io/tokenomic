// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Libs {
    function getPercent(uint256 _percent, uint256 _from)
        public
        pure
        returns (uint256)
    {
        return (_from * _percent) / 100;
    }

    function calcMintedTokens(
        uint256 _activePlayers,
        uint256 _pool,
        uint256 _GFindex
    ) public pure returns (uint256) {
        uint256 controversy = (100 - _activePlayers); 
        uint256 averageBet = _pool / _activePlayers; 
        return (averageBet * _activePlayers * controversy * _GFindex) / 10000;
    }
}
