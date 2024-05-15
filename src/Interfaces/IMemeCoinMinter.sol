// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMemeCoinMinter {
    /// @notice Emitted when meme coin has been minted to all participants
    /// @param coinAddress Meme coin ERC20 token address
    /// @param coinName Meme coin name
    /// @param coinSymbol Meme coin symbol
    event MemeCoinMinted(address indexed coinAddress, string coinName, string coinSymbol);

    /// @param name Name of new ERC20 Meme Token
    /// @param symbol Symbol of new ERC20 Meme Token
    /// @param creator Meme creator wallet address
    /// @param team Dex Your Meme team wallet address
    /// @param recipients Array parallel to 'amounts[]' contains all funders of new ERC20 Meme Token
    /// @param amounts Array parallel to 'recipients[]' contains all funds of new ERC20 Meme Token
    /// @param totalFunds Sum of ETH gathered for new ERC20 Meme Token
    /// @param mcd MemeCoinDexer contract address
    struct MintParams {
        string name;
        string symbol;
        address creator;
        address team;
        address[] recipients;
        uint256[] amounts;
        uint256 totalFunds;
        address mcd;
    }

    /// @notice Deploys new ERC20 Meme Token
    /// @param params The params necessary to mint and request coin dexing, encoded as `MintParams` in calldata
    function mintCoinAndRequestDex(MintParams calldata params) external;
}
