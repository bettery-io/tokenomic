// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {BET} from "./BET.sol";
import {MetaTransactLib} from "../../metaTransaction/MetaTransactLib.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";

contract BTY is ERC20Upgradeable, MetaTransactLib, ConfigVariables {
    BET private betToken;

    address public childChainManagerProxy;
    mapping(address => bool) public wallets;

    function __BTYinit(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        BET _betAddress,
        address _childChainManagerProxy,
        uint _network_id
    ) public initializer {
        __ERC20_init(_name, _symbol);
        _setupDecimals(_decimals);
        __MetaTransactLibInit("BTY_token", "1", _network_id);
        betToken = _betAddress;
        childChainManagerProxy = _childChainManagerProxy;
    }

    function swipe(uint256 _amount) public {
        require(
            betToken.balanceOf(msgSender()) >= _amount,
            "not enough tokens"
        );
        betToken.burn(msgSender(), _amount);
        _mint(msgSender(), _amount);
    }

    function updateChildChainManager(address newChildChainManagerProxy)
        external
        ownerOnly()
    {
        require(
            newChildChainManagerProxy != address(0),
            "Bad ChildChainManagerProxy address"
        );
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
            require(amount >= getFirstWithdraw(), "do not have enough tokens for first withdraw");
            wallets[msgSender()] = true;
            _burn(msgSender(), amount);
        }
    }
}
