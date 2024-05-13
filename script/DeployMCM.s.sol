// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoinMinter} from "../src/MemeCoinMinter.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMCM is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("LOCAL_PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        MemeCoinMinter mcm = new MemeCoinMinter();
        console.log("Deployed Dex Youe Meme:", address(mcm));
        console.log("Owner: ", mcm.owner());
        vm.stopBroadcast();
    }
}
