// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@solmate/src/utils/ReentrancyGuard.sol";

contract DYMFundsManager is Ownable, ReentrancyGuard {
    /// @dev Constructor
    constructor() Ownable(msg.sender) {}
}
