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

    /// @notice Collects up to a maximum amount of fees owed to a specific position to the recipient
    /// @param tokenId The ID of the NFT for which tokens are being collected
    function collect(uint tokenId) external payable;

    ///************************************************************************************************//
    /// @dev THIS FUNCTION IS BLOCKED FOR 1 YEAR TO PREVENT RUG PULL ACTIONS ON NEWLY DEXED MEME COINS //
    ///************************************************************************************************//
    /// @notice Decreases the amount of liquidity in a position and accounts it to the position
    /// @param tokenId The ID of the token for which liquidity is being decreased
    /// @param liquidity The amount by which liquidity will be decreased
    /// @param memeTokenAmount The minimum amount of token0 that should be accounted for the burned liquidity
    /// @param wethAmount The minimum amount of token1 that should be accounted for the burned liquidity
    function decreaseLiquidity(uint tokenId, uint128 liquidity, uint memeTokenAmount, uint wethAmount) external payable;

    ///************************************************************************************************//
    /// @dev THIS FUNCTION IS BLOCKED FOR 1 YEAR TO PREVENT RUG PULL ACTIONS ON NEWLY DEXED MEME COINS //
    ///************************************************************************************************//
    /// @notice Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens must be collected first.
    /// @param tokenId The ID of the token that is being burned
    function burn(uint tokenId) external payable;

    /// @notice Allows to withdraw all coins pending on contract after pool initialization (Q64.96 price format inaccuracy)
    /// @param coin Address of dexed and burned meme coin or weth
    function gatherCoins(address coin) external;
}
