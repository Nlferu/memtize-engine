// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoinMinter} from "../src/MemeCoinMinter.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMCM is Script {
    function run() external returns (MemeCoinMinter) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        MemeCoinMinter memeCoinMinter = new MemeCoinMinter();
        console.log("Deployed Meme Coin Minter:", address(memeCoinMinter));
        console.log("Owner: ", memeCoinMinter.owner());
        vm.stopBroadcast();

        return memeCoinMinter;
    }
}
