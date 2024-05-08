// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev This Token Template will be used for all Meme Coins crafting
 * No additional mint/burn functionality -> in order to prevent rugged price manipulation actions
 * Transparent and clear division of fixed and final supply -> no option for hidden tokens amount, which could cause serious price drops
 */

contract MemeCoin is ERC20 {
    /// @dev Errors
    error MC__ArraysNotParallel();

    /// @dev Constants
    uint256 private constant TOTAL_SUPPLY = 1_000_000 * (10 ** 18);
    uint256 private constant CREATOR_PERCENT = 15;
    uint256 private constant TEAM_PERCENT = 5;
    uint256 private constant FUNDERS_PERCENT = 35;
    uint256 private constant LIQUIDITY_POOL_PERCENT = 45;

    /// @param name Name of new ERC20 Meme Token
    /// @param symbol Symbol of new ERC20 Meme Token
    /// @param creator Meme creator wallet address
    /// @param team Dex Your Meme team wallet address
    /// @param funders Array parallel to 'amounts[]' contains all funders of new ERC20 Meme Token
    /// @param amounts Array parallel to 'funders[]' contains all funds of new ERC20 Meme Token
    /// @param totalFunds Sum of ETH gathered for new ERC20 Meme Token */
    /// @param dym DexYourMeme contract address
    constructor(
        string memory name,
        string memory symbol,
        address creator,
        address team,
        address[] memory funders,
        uint256[] memory amounts,
        uint totalFunds,
        address dym
    ) ERC20(name, symbol) {
        if (funders.length != amounts.length) revert MC__ArraysNotParallel();

        /// @dev Minting tokens for the creator, team, and liquidity pool
        _mint(creator, (TOTAL_SUPPLY * CREATOR_PERCENT) / 100);
        _mint(team, (TOTAL_SUPPLY * TEAM_PERCENT) / 100);
        _mint(dym, (TOTAL_SUPPLY * LIQUIDITY_POOL_PERCENT) / 100);

        /// @dev Minting tokens for funders proportionally to their contributions
        uint256 fundersTokens = (TOTAL_SUPPLY * FUNDERS_PERCENT) / 100;

        for (uint256 i = 0; i < funders.length; i++) {
            uint256 funderTokens = (fundersTokens * amounts[i]) / totalFunds;
            _mint(funders[i], funderTokens);
        }
    }
}
