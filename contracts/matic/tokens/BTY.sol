// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {BET} from "./BET.sol";
import {MetaTransactLib} from "../../metaTransaction/MetaTransactLib.sol";

contract BTY is MetaTransactLib {
    BET private betToken;
    address owner;

    address public childChainManagerProxy;
    mapping(address => bool) public wallets;

    function __BTYinit(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _childChainManagerProxy,
        uint _network_id
    ) public initializer {
        __EIP712BaseInit("BTY_token", "1", _network_id);
        __ERC20_init(_name, _symbol);
        _setupDecimals(_decimals);
        childChainManagerProxy = _childChainManagerProxy;
        owner = msg.sender;
    }

    function setBETaddr(BET _betAddress) public {
        require(msg.sender == owner, "owner only");
        betToken = _betAddress;
    }

    function swipe(uint256 _amount) public {
        require(
            betToken.balanceOf(_msgSender()) >= _amount,
            "not enough tokens"
        );
        betToken.burn(_msgSender(), _amount);
        _mint(_msgSender(), _amount);
    }

    function updateChildChainManager(address newChildChainManagerProxy)
        external
    {
        require(
            newChildChainManagerProxy != address(0),
            "Bad ChildChainManagerProxy address"
        );
        require(msg.sender == owner, "owner only");
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
        if (wallets[_msgSender()]) {
            _burn(_msgSender(), amount);
        } else {
            require(amount >= betToken.getFirstWithdraw(), "do not have enough tokens for first withdraw");
            wallets[_msgSender()] = true;
            _burn(_msgSender(), amount);
        }
    }
}
