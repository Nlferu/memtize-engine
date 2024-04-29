// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DexYourMeme} from "../src/DexYourMeme.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployDYM is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("LOCAL_PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        DexYourMeme dym = new DexYourMeme();
        console.log("Deployed Dex Youe Meme:", address(dym));
        vm.stopBroadcast();
    }
}
