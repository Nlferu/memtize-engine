// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoinDexer} from "../src/MemeCoinDexer.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMCD is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        address mcm = 0xFb94678b88d20B897ac145C319297E1B30223090; // -> tmp random value
        MemeCoinDexer mcd = new MemeCoinDexer(mcm);
        console.log("Deployed Meme Coin Dexer:", address(mcd));
        console.log("Owner: ", mcd.owner());
        vm.stopBroadcast();
    }
}
