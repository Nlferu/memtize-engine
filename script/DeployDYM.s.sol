// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DexYourMeme} from "../src/DexYourMeme.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployDYM is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        address mcm = 0xFb94678b88d20B897ac145C319297E1B30223090; // -> tmp random value
        DexYourMeme dym = new DexYourMeme(mcm);
        console.log("Deployed Dex Your Meme:", address(dym));
        vm.stopBroadcast();
    }
}
