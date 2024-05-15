// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoin} from "./MemeCoin.sol";
import {IMemeCoinDexer} from "./Interfaces/IMemeCoinDexer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev This contract acts as a meme coin factory. Once a meme coin is successfully created, it requests listing on Uniswap
 */

contract MemeCoinMinter is Ownable {
    /// @dev Events
    event MemeCoinMinted(address indexed coinAddress, string coinName, string coinSymbol);

    /// @dev Constructor
    /// @notice Owner of this contract is DFM contract
    constructor() Ownable(msg.sender) {}

    /////////////////////// @notice MCM External Functions (Callable only by DFM contract) ///////////////////////

    /// @notice Deploys new ERC20 Meme Token
    /// @param name Name of new ERC20 Meme Token
    /// @param symbol Symbol of new ERC20 Meme Token
    /// @param creator Meme creator wallet address
    /// @param team Dex Your Meme team wallet address
    /// @param recipients Array parallel to 'amounts[]' contains all funders of new ERC20 Meme Token
    /// @param amounts Array parallel to 'recipients[]' contains all funds of new ERC20 Meme Token
    /// @param totalFunds Sum of ETH gathered for new ERC20 Meme Token
    /// @param mcd MemeCoinDexer contract address
    function mintCoinAndRequestDex(
        string memory name,
        string memory symbol,
        address creator,
        address team,
        address[] memory recipients,
        uint[] memory amounts,
        uint totalFunds,
        address mcd
    ) external onlyOwner {
        MemeCoin newCoin = new MemeCoin(name, symbol, creator, team, recipients, amounts, totalFunds, mcd);

        emit MemeCoinMinted(address(newCoin), name, symbol);

        IMemeCoinDexer(mcd).dexMeme(address(newCoin));

        emit IMemeCoinDexer.MemeDexRequestReceived(address(newCoin));
    }
}
