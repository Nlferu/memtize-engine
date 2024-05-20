// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MemeCoinMinter} from "../src/MemeCoinMinter.sol";

contract DeployMCM is Script {
    function run() external returns (MemeCoinMinter) {
        HelperConfig helperConfig = new HelperConfig();
        (, , , uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        MemeCoinMinter memeCoinMinter = new MemeCoinMinter();
        console.log("Deployed Meme Coin Minter:", address(memeCoinMinter));
        console.log("Owner: ", memeCoinMinter.owner());
        vm.stopBroadcast();

        return memeCoinMinter;
    }
}
