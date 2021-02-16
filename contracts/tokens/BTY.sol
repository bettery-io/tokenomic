// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BET} from "./BET.sol";
import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";

contract BTY is ERC20, MetaTransactLib, ConfigVariables {
    BET private betToken;

    address public childChainManagerProxy;
    address deployer;
    mapping(address => bool) public wallets;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        BET _betAddress,
        address _childChainManagerProxy
    ) ERC20(_name, _symbol) MetaTransactLib("BTY_token", "1", 5) {
        betToken = _betAddress;
        childChainManagerProxy = _childChainManagerProxy;
        deployer = msg.sender;
        _setupDecimals(_decimals);
    }

    function swipe(uint256 _amount) public {
        require(
            betToken.balanceOf(msgSender()) >= _amount,
            "do not enought tokens"
        );
        betToken.burn(_amount);
        _mint(msgSender(), _amount);
    }

    function updateChildChainManager(address newChildChainManagerProxy)
        external
    {
        require(
            newChildChainManagerProxy != address(0),
            "Bad ChildChainManagerProxy address"
        );
        require(msg.sender == deployer, "You're not allowed");

        childChainManagerProxy = newChildChainManagerProxy;
    }

    function deposit(address user, bytes calldata depositData) external {
        require(
            msg.sender == childChainManagerProxy,
            "You're not allowed to deposit"
        );

        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    function withdraw(uint256 amount) external {
        if (wallets[msgSender()]) {
            _burn(msgSender(), amount);
        } else {
            if(amount >= getFirstWithdraw()){
                wallets[msgSender()] = true;
               _burn(msgSender(), amount);
            }
        }
    }
    
}
