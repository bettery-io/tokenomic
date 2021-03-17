// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {NetworkAgnostic} from "./common/NetworkAgnostic.sol";

contract MetaTransactLib is AccessControl, NetworkAgnostic {

    constructor(
        string memory _name, 
        string memory _version, 
        uint _chain_id 
    ) NetworkAgnostic(_name, _version, _chain_id){}
    
    function msgSender()
        internal
        view
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}    