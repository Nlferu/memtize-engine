// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoin} from "./MemeCoin.sol";
import {IDexYourMeme} from "./Interfaces";

/// @dev TODO: This needs to be callable only by DFM contract
contract MemeCoinMinter {
    /// @dev Arrays
    address[] private tokens;

    /// @dev Events
    event MemeCoinMinted(address indexed coinAddress, string coinName, string coinSymbol);

    /** @notice Deploys new ERC20 Meme Token */
    /** @param name Name of new ERC20 Meme Token */
    /** @param symbol Symbol of new ERC20 Meme Token */
    /** @param creator Meme creator wallet address */
    /** @param team Dex Your Meme team wallet address */
    /** @param recipients Array parallel to 'amounts[]' contains all funders of new ERC20 Meme Token */
    /** @param amounts Array parallel to 'recipients[]' contains all funds of new ERC20 Meme Token */
    /** @param totalFunds Sum of ETH gathered for new ERC20 Meme Token */
    /** @param dym DexYourMeme contract address */
    function mintCoinAndRequestDex(
        string memory name,
        string memory symbol,
        address creator,
        address team,
        address[] memory recipients,
        uint[] memory amounts,
        uint totalFunds,
        address dym
    ) external {
        MemeCoin newCoin = new MemeCoin(name, symbol, creator, team, recipients, amounts, totalFunds, dym);

        tokens.push(address(newCoin));

        emit MemeCoinMinted(address(newCoin), name, symbol);

        IDexYourMeme(dym).dexMeme(address(newCoin));
    }

    function getTokensMinted() external view returns (address[] memory) {
        return tokens;
    }
}
