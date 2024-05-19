// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoin} from "./MemeCoin.sol";
import {IMemeCoinDexer} from "./Interfaces/IMemeCoinDexer.sol";
import {IMemeCoinMinter} from "./Interfaces/IMemeCoinMinter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev This contract acts as a meme coin factory. Once a meme coin is successfully created, it requests listing on Uniswap
 */

contract MemeCoinMinter is IMemeCoinMinter, Ownable {
    /// @dev Constructor
    /// @notice Owner of this contract is DFM contract
    constructor() Ownable(msg.sender) {}

    /////////////////////// @notice MCM External Functions (Callable only by DFM contract) ///////////////////////

    /// @notice Deploys new ERC20 Meme Token
    /// @param params IMemeCoinMinter
    function mintCoinAndRequestDex(MintParams calldata params) external onlyOwner {
        MemeCoin newCoin = new MemeCoin(params);

        emit MemeCoinMinted(address(newCoin), params.name, params.symbol);

        IMemeCoinDexer(params.mcd).dexMeme(address(newCoin), params.totalFunds, params.totalMemeCoins);

        emit IMemeCoinDexer.MemeDexRequestReceived(address(newCoin));
    }
}
