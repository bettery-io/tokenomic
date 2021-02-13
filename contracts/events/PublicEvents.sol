// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {PubStruct} from "../struct/PubStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";

contract PublicEvents is MetaTransactLib, TimeValidation {
    constructor() MetaTransactLib("Public_contract", "1", 5) {}
}