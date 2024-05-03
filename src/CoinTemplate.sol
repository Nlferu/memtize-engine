// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CoinTemplate is ERC20 {
    error CT__ArraysNotParrarell();

    uint256 private constant TOTAL_SUPPLY = 1_000_000 * (10 ** 18);
    uint256 private constant CREATOR_PERCENT = 15;
    uint256 private constant TEAM_PERCENT = 5;
    uint256 private constant FUNDERS_PERCENT = 35;
    uint256 private constant LIQUIDITY_POOL_PERCENT = 45;

    constructor(
        string memory name,
        string memory symbol,
        address creatorAddress,
        address teamAddress,
        address[] memory funders,
        uint256[] memory amounts,
        uint totalFunds,
        address dym
    ) ERC20(name, symbol) {
        if (funders.length != amounts.length) revert CT__ArraysNotParrarell();

        /// @dev Minting tokens for the creator, team, and liquidity pool
        _mint(creatorAddress, (TOTAL_SUPPLY * CREATOR_PERCENT) / 100);
        _mint(teamAddress, (TOTAL_SUPPLY * TEAM_PERCENT) / 100);
        _mint(dym, (TOTAL_SUPPLY * LIQUIDITY_POOL_PERCENT) / 100);

        /// @dev Minting tokens for funders proportionally to their contributions
        uint256 fundersTokens = (TOTAL_SUPPLY * FUNDERS_PERCENT) / 100;

        for (uint256 i = 0; i < funders.length; i++) {
            uint256 funderTokens = (fundersTokens * amounts[i]) / totalFunds;
            _mint(funders[i], funderTokens);
        }
    }
}
