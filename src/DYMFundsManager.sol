// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@solmate/src/utils/ReentrancyGuard.sol";

// This -> Minter -> Dex

contract DYMFundsManager is Ownable, ReentrancyGuard {
    /// @dev Constants
    uint256 private constant SUPPLY = 1000000;

    /// @dev Variables
    uint256 private s_totalMemes;

    /// @dev Enums
    enum MemeStatus {
        ALIVE,
        DEAD
    }

    /// @dev Structs
    struct Meme {
        address idToCreator;
        string idToName;
        string idToSymbol;
        uint256 idToTime;
        uint256 idToTotalFunds;
        mapping(address => uint256) idToFunderToFunds;
        MemeStatus idToMemeStatus;
    }

    /// @dev Mappings
    mapping(uint256 => Meme) private s_memes;
    mapping(address => uint256) private funderToFunds;

    /// @dev Constructor
    constructor() Ownable(msg.sender) {}

    function createMeme() external {}

    // This will send request to Minter for creation of meme
    function hypeMeme() internal {}

    // If 1 month will pass this will kill funding of meme
    function killMeme() internal {}

    function fundMeme() external {}

    function refund() external {}
}
