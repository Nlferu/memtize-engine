// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDexYourMeme {
    /// @notice Emitted when liquidity has been provided for token
    /// @param token Meme coin that got dexed
    event MemeDexedSuccessfully(address indexed token);

    /// @notice Creating, initializing and adding liquidity pool for new meme token
    /// @param memeToken Meme token address to be dexed
    function dexMeme(address memeToken) external;
}
