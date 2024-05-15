// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeProcessManager} from "../src/MemeProcessManager.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMPM is Script {
    function run(address mcm, address mcd, uint interval) external returns (MemeProcessManager) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        MemeProcessManager memeProcessManager = new MemeProcessManager(mcm, mcd, interval);
        console.log("Deployed Meme Process Manager:", address(memeProcessManager));
        console.log("Owner: ", memeProcessManager.owner());
        vm.stopBroadcast();

        return memeProcessManager;
    }
}
