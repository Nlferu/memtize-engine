// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@solmate/src/utils/ReentrancyGuard.sol";

contract DYMFundsManager is Ownable, ReentrancyGuard {
    /// @dev Variables
    uint256 private s_totalMemes;

    /// @dev Structs
    struct Memes {
        uint256 idToAddressToFunds;
    }

    /// @dev Mappings
    mapping(uint256 => Memes) private s_memes;

    /// @dev Constructor
    constructor() Ownable(msg.sender) {}

    function createMeme() external {}
}
