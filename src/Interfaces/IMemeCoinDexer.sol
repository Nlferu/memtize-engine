// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMemeCoinDexer {
    /// @notice Emitted when dexMeme function has been executed for token
    /// @param token Meme coin that got dexed
    event MemeDexRequestReceived(address indexed token);

    /// @notice Creates, initializes and adds liquidity pool for new meme token
    /// @param memeToken Meme token address to be dexed
    /// @param wethAmount WETH tokens amount
    /// @param memeCoinAmount Meme coin tokens amount
    function dexMeme(address memeToken, uint wethAmount, uint memeCoinAmount) external;
}
