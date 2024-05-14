// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeManagementHub} from "../src/MemeManagementHub.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMMH is Script {
    function run(address team, address mcm, uint interval) external {
        uint256 deployerKey = vm.envUint("LOCAL_PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        MemeManagementHub mmh = new MemeManagementHub(team, mcm, interval);
        console.log("Deployed Meme Management Hub:", address(mmh));
        console.log("Owner: ", mmh.owner());
        vm.stopBroadcast();
    }
}
