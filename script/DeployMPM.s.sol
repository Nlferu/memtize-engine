// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MemeProcessManager} from "../src/MemeProcessManager.sol";

contract DeployMPM is Script {
    uint private constant INTERVAL = 30;

    function run(address mcm, address mcd) external returns (MemeProcessManager) {
        HelperConfig helperConfig = new HelperConfig();
        (, , , uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        MemeProcessManager memeProcessManager = new MemeProcessManager(mcm, mcd, INTERVAL);
        console.log("Deployed Meme Process Manager:", address(memeProcessManager));
        console.log("Owner: ", memeProcessManager.owner());
        vm.stopBroadcast();

        return memeProcessManager;
    }
}
