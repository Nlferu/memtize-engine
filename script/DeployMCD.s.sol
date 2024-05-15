// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MemeCoinDexer} from "../src/MemeCoinDexer.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployMCD is Script {
    function run(address memeCoinMinter) external returns (MemeCoinDexer) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        MemeCoinDexer memeCoinDexer = new MemeCoinDexer(memeCoinMinter);
        console.log("Deployed Meme Coin Dexer:", address(memeCoinDexer));
        console.log("Owner: ", memeCoinDexer.owner());
        vm.stopBroadcast();

        return memeCoinDexer;
    }
}
