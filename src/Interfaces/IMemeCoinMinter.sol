// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMemeCoinMinter {
    /// @notice Emitted when meme coin has been minted to all participants
    /// @param coinAddress Meme coin ERC20 token address
    /// @param coinName Meme coin name
    /// @param coinSymbol Meme coin symbol
    event MemeCoinMinted(address indexed coinAddress, string coinName, string coinSymbol);

    struct MintParams {
        string name;
        string symbol;
        address creator;
        address team;
        address[] recipients;
        uint256[] amounts;
        uint256 totalFunds;
        address dym;
    }

    /// @notice Deploys new ERC20 Meme Token
    /// @param params The params necessary to mint and request coin dexing, encoded as `MintParams` in calldata
    function mintCoinAndRequestDex(MintParams calldata params) external;
}
