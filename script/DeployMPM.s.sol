// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeProcessManager} from "../src/MemeProcessManager.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMPM is Script {
    function run(address team, address mcm, uint interval) external {
        uint256 deployerKey = vm.envUint("LOCAL_PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        MemeProcessManager mpm = new MemeProcessManager(team, mcm, interval);
        console.log("Deployed Meme Process Manager:", address(mpm));
        console.log("Owner: ", mpm.owner());
        vm.stopBroadcast();
    }
}
