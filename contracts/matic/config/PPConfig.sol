// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract PPConfig is Initializable {
    address owner;
    // PLAYERS
    uint256 public playersPersMint; // mint token percent for players
    uint256 public playersPers; // pay token percent for players
    uint256 public playersPersPremiun; // pay token percent for players in Premium events
    uint256 public firstRefer; // first level of referrers;
    uint256 public secontRefer; // second level of referrers;
    uint256 public thirdRefer; // third level of referrers;
    address fakeAddr;

    function __PPConfigInit(
        uint256 _playersPersMint,
        uint256 _playersPers,
        uint256 _playersPersPremiun,
        uint256 _firstRefer,
        uint256 _secontRefer,
        uint256 _thirdRefer,
        address _fakeAddr
    ) public initializer {
        owner = msg.sender;
        playersPersMint = _playersPersMint;
        playersPers = _playersPers;
        playersPersPremiun = _playersPersPremiun;
        firstRefer = _firstRefer;
        secontRefer = _secontRefer;
        thirdRefer = _thirdRefer;
        fakeAddr = _fakeAddr;
    }

    function setPlayerPercMint(
        uint256 _playersPersMint,
        uint256 _playersPers,
        uint256 _playersPersPremiun
    ) public {
        require(msg.sender == owner, "owner only");
        playersPersMint = _playersPersMint;
        playersPers = _playersPers;
        playersPersPremiun = _playersPersPremiun;
    }

    function setReferrersPerc(
        uint256 _firstRefer,
        uint256 _secontRefer,
        uint256 _thirdRefer
    ) public {
        require(msg.sender == owner, "owner only");
        firstRefer = _firstRefer;
        secontRefer = _secontRefer;
        thirdRefer = _thirdRefer;
    }

    function setFakeAddr(address _fake) public {
        require(msg.sender == owner, "owner only");
        fakeAddr = _fake;
    }
}
