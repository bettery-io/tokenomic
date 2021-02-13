// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BTY is ERC20 {
        constructor(
         string memory _name,
         string memory _symbol,
         uint8 _decimals,
         uint256 _initialSupplyCoins
        ) ERC20(_name, _symbol) {
            _setupDecimals(_decimals);
            _mint(msg.sender, _initialSupplyCoins * (10**uint256(_decimals)));
        }

}