// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {NetworkAgnostic} from "./common/NetworkAgnostic.sol";

contract MetaTransactLib is AccessControlUpgradeable, NetworkAgnostic {

    function __MetaTransactLibInit(
        string memory _name, 
        string memory _version, 
        uint _chain_id 
    ) public initializer{
        __NetworkAgnosticInit(_name, _version, _chain_id);
    }
    
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