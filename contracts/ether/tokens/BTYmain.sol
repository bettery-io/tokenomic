// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MetaTransactLib} from "../../metaTransaction/MetaTransactLib.sol";

contract BTYmain is ERC20, MetaTransactLib {
    address public owner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupplyCoins,
        uint _network_id
    ) payable ERC20(_name, _symbol) MetaTransactLib("BET_main", "1", _network_id)  
    {
        owner = msg.sender;
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
