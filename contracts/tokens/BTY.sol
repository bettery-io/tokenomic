// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BET} from "./BET.sol";
import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";

contract BTY is ERC20, MetaTransactLib {
    BET private betToken;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupplyCoins,
        BET _betAddress
    ) ERC20(_name, _symbol) MetaTransactLib("BTY_token", "1", 5) {
        betToken = _betAddress;
        _setupDecimals(_decimals);
        _mint(msg.sender, _initialSupplyCoins * (10**uint256(_decimals)));
    }

    function swipe(uint256 _amount) public {
        require(
            betToken.balanceOf(msgSender()) >= _amount,
            "do not enought tokens"
        );
        betToken.burn(_amount);
        _mint(msgSender(), _amount);
    }
}
