// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MemeCoinDexer} from "../src/MemeCoinDexer.sol";
import {IMemeCoinDexer} from "../src/Interfaces/IMemeCoinDexer.sol";
import {IUniswapV3Pool} from "../src/Interfaces/IUniswapV3Pool.sol";

contract Collect is Script {
    function run(address mcd, uint tokenId) external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        IMemeCoinDexer(mcd).collect(tokenId);
        vm.stopBroadcast();
    }
}

contract DecreaseLiquidity is Script {
    uint private constant SLIPPAGE = 1;

    function run(address mcd, uint tokenId, address pool) external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        uint128 liquidity = IUniswapV3Pool(pool).liquidity();

        vm.startBroadcast(deployerKey);
        IMemeCoinDexer(mcd).decreaseLiquidity(tokenId, liquidity, SLIPPAGE, SLIPPAGE);
        vm.stopBroadcast();
    }
}

contract Burn is Script {
    function run(address mcd, uint tokenId) external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        IMemeCoinDexer(mcd).burn(tokenId);
        vm.stopBroadcast();
    }
}

contract GatherCoins is Script {
    function run(address mcd, address coin) external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        IMemeCoinDexer(mcd).gatherCoins(coin);
        vm.stopBroadcast();
    }
}
