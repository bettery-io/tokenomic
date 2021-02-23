// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";

contract BET is MetaTransactLib, ERC20, ConfigVariables {
    address publicContract;
    address btyContract;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol) MetaTransactLib("BET_token", "1", 5) {
        _setupDecimals(_decimals);
    }

    function setConfigContract(address _publicEvents, address _bty) public ownerOnly() {
        publicContract = _publicEvents;
        btyContract = _bty;
    }

    function mint(address wallet) public ownerOnly() {
        require(balanceOf(wallet) == 0, "User has tokens on balance");
        uint256 amount = getWelcomeBTYTokens();
        _mint(wallet, amount);
    }

    function mintPublicContract(address wallet, uint256 amount) public {
        require(
            msg.sender == publicContract,
            "This function could only be executed by the public contract"
        );
        _mint(wallet, amount);
    }

    function burn(address wallet, uint256 amount) public {
        require(msg.sender == btyContract, "Only BTY tokens can burn BET tokens");
        _burn(wallet, amount);
    }
}
