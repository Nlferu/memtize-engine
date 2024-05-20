// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MemeCoinDexer} from "../src/MemeCoinDexer.sol";

contract DeployMCD is Script {
    function run(address memeCoinMinter) external returns (MemeCoinDexer) {
        HelperConfig helperConfig = new HelperConfig();
        (address nftPositionManager, address wrappedNativeToken, , uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        MemeCoinDexer memeCoinDexer = new MemeCoinDexer(memeCoinMinter, nftPositionManager, wrappedNativeToken);
        console.log("Deployed Meme Coin Dexer:", address(memeCoinDexer));
        console.log("Owner: ", memeCoinDexer.owner());
        vm.stopBroadcast();

        return memeCoinDexer;
    }
}
