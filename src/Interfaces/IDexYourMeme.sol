// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDexYourMeme {
    /// @notice Creating, initializing and adding liquidity pool for new meme token
    /// @param memeToken Meme token address to be dexed
    function dexMeme(address memeToken) external;
}
