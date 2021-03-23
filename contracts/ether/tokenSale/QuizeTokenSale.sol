// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {BTYmain} from "../tokens/BTYmain.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract QuizeTokenSale is Initializable {
    address payable owner;
    BTYmain public tokenContract;
    BTYmain public usdttoken;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);

    function __QuizeTokenSaleInit(BTYmain _tokenContract, uint256 _tokenPrice, BTYmain _usdttoken) public initializer {
        usdttoken = _usdttoken;
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        uint256 numberOfTokens = _numberOfTokens / 1000000000000000000;
        uint256 numberOfUSDTtoken = multiply(numberOfTokens, tokenPrice);
        require(usdttoken.allowance(msg.sender, address(this)) >= numberOfUSDTtoken, "allowance error");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "do not enought tokens");
        require(usdttoken.transferFrom(msg.sender, address(this), numberOfUSDTtoken), "transfer usdt error");
        require(tokenContract.transfer(msg.sender, _numberOfTokens), "transfer bettry error");
        tokensSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == owner, "you are not a owner");
        require(tokenContract.transfer(owner,tokenContract.balanceOf(address(this))),"can not transfer money");
    }

    function updatePrice(uint256 _tokenPrice) public {
        require(msg.sender == owner, "you are not a owner");
        tokenPrice = _tokenPrice;
    }

    function test3() public pure returns(uint){
        return 10 + 10;
    }
}
