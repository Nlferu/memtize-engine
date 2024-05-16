// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IMemeCoinMinter} from "./Interfaces/IMemeCoinMinter.sol";

/**
 * @dev This is token template that will be used for all meme coins crafting
 * No additional mint/burn functionality -> in order to prevent rugged price manipulation actions
 * Transparent and clear division of fixed and final supply -> no option for hidden tokens amount, which could cause serious price drops
 */

contract MemeCoin is ERC20 {
    /// @dev Errors
    error MC__ArraysNotParallel();

    /// @dev Constants
    uint private constant CREATOR_PERCENT = 15;
    uint private constant TEAM_PERCENT = 5;
    uint private constant FUNDERS_PERCENT = 35;
    uint private constant LIQUIDITY_POOL_PERCENT = 45;

    /// @param params IMemeCoinMinter
    constructor(IMemeCoinMinter.MintParams memory params) ERC20(params.name, params.symbol) {
        if (params.recipients.length != params.amounts.length) revert MC__ArraysNotParallel();

        /// @dev Minting tokens for the creator, team, and liquidity pool
        _mint(params.creator, (params.totalMemeCoins * CREATOR_PERCENT) / 100);
        _mint(params.team, (params.totalMemeCoins * TEAM_PERCENT) / 100);
        _mint(params.mcd, (params.totalMemeCoins * LIQUIDITY_POOL_PERCENT) / 100);

        /// @dev Minting tokens for funders proportionally to their contributions
        uint fundersTokens = (params.totalMemeCoins * FUNDERS_PERCENT) / 100;

        for (uint i = 0; i < params.recipients.length; i++) {
            uint funderTokens = (fundersTokens * params.amounts[i]) / params.totalFunds;
            _mint(params.recipients[i], funderTokens);
        }
    }
}
