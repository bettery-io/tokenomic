// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {MetaTransactLib} from "../helpers/MetaTransactLib.sol";
import {GFStruct} from "../struct/GFStruct.sol";
import {TimeValidation} from "../helpers/TimeValidation.sol";

contract GrowthFactorEvents is MetaTransactLib, TimeValidation {
    constructor() MetaTransactLib("GrowthFactor_contract", "1", 5) {}
    //TODO

}    