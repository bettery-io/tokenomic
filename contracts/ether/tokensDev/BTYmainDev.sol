// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../../metaTransaction/MetaTransactLib.sol";

contract BTYmainDev is MetaTransactLib {
    address public owner;

    function __BTYmainInit(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupplyCoins,
        uint _network_id
    ) public initializer
    {
        owner = msg.sender;
        __EIP712BaseInit("BET_main", "1", _network_id);  
        __ERC20_init(_name, _symbol);
        _setupDecimals(_decimals);
        _mint(msg.sender, _initialSupplyCoins);
    }

    function mint(uint256 amount, address payable wallet) public {
        require(msg.sender == owner, "you are not a owner");
        _mint(wallet, amount);
    }

    function burn(uint256 amount, address payable wallet) public {
        require(msg.sender == owner, "you are not a owner");
        _burn(wallet, amount);
    }
}