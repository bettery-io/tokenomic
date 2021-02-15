// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";

contract BET is MetaTransactLib, ERC20 {
    address publicContract;
    address owner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupplyCoins
    ) ERC20(_name, _symbol) MetaTransactLib("BET_token", "1", 5) {
        owner = msg.sender;
        _setupDecimals(_decimals);
        _mint(msg.sender, _initialSupplyCoins * (10**uint256(_decimals)));
    }

    function setPublicContract(address wallet) public {
        require(
            msgSender() == owner,
            "This function could only be executed by the owner"
        );
        publicContract = wallet;
    }

    function mint(address wallet, uint256 amount ) public{
        require(
            msgSender() == publicContract,
            "This function could only be executed by the public contract"
        );
        _mint(wallet, amount);
    }

    function burn(uint256 amount) public {
        _burn(msgSender(), amount);
    }
}
