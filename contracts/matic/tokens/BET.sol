// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../../metaTransaction/MetaTransactLib.sol";
import {ConfigVariables} from "../config/ConfigVariables.sol";

contract BET is MetaTransactLib, ConfigVariables {
    address publicContract;
    address btyContract;

    function __BETinit(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint _network_id,
        uint _firstWithdrawIndex,
        uint _GFrewards,
        uint _welcomeBTYTokens,
        uint _GFindex
    ) public initializer {
        __EIP712BaseInit("BET_token", "1", _network_id);
        __ConfigVariables(
            _firstWithdrawIndex,
            _GFrewards,
            _welcomeBTYTokens,
            _GFindex
        );
        __ERC20_init(_name, _symbol);
        _setupDecimals(_decimals);
    }

    function setConfigContract(address _publicEvents, address _bty)
        public
        ownerOnly()
    {
        publicContract = _publicEvents;
        btyContract = _bty;
    }

    function mint(address wallet) public ownerOnly() {
        //    require(balanceOf(wallet) == 0, "User has tokens on balance"); TODO remove from prodaction
        _mint(wallet, welcomeBTYTokens);
    }

    function mintFromPublicContract(address wallet, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == publicContract, "only public contract");
        _mint(wallet, amount);
        return true;
    }

    function burn(address wallet, uint256 amount) public {
        require(msg.sender == btyContract, "BTY can burn BET");
        _burn(wallet, amount);
    }
}
