// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoin} from "./MemeCoin.sol";
import {IDexYourMeme} from "./Interfaces/IDexYourMeme.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @dev TODO: This needs to be callable only by DFM contract
contract MemeCoinMinter is Ownable {
    /// @dev Events
    event MemeCoinMinted(address indexed coinAddress, string coinName, string coinSymbol);

    /// @dev Constructor
    /// @notice Owner of this contract will be DFM contract just after deployment
    constructor() Ownable(msg.sender) {}

    /// @notice Deploys new ERC20 Meme Token
    /// @param name Name of new ERC20 Meme Token
    /// @param symbol Symbol of new ERC20 Meme Token
    /// @param creator Meme creator wallet address
    /// @param team Dex Your Meme team wallet address
    /// @param recipients Array parallel to 'amounts[]' contains all funders of new ERC20 Meme Token
    /// @param amounts Array parallel to 'recipients[]' contains all funds of new ERC20 Meme Token
    /// @param totalFunds Sum of ETH gathered for new ERC20 Meme Token
    /// @param dym DexYourMeme contract address
    function mintCoinAndRequestDex(
        string memory name,
        string memory symbol,
        address creator,
        address team,
        address[] memory recipients,
        uint[] memory amounts,
        uint totalFunds,
        address dym
    ) external onlyOwner {
        MemeCoin newCoin = new MemeCoin(name, symbol, creator, team, recipients, amounts, totalFunds, dym);

        emit MemeCoinMinted(address(newCoin), name, symbol);

        IDexYourMeme(dym).dexMeme(address(newCoin));

        emit IDexYourMeme.MemeDexRequestReceived(address(newCoin));
    }
}
