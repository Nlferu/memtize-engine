// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DexYourMeme} from "../src/DexYourMeme.sol";
import {Script, console} from "forge-std/Script.sol";

error Interaction_Failed();

contract SwapETH is Script {
    address private constant DYM_ADDRESS = 0x5f101cdB70bB7081D8AEa072c4E43c6f046A76fE;

    function run() external {
        swap();
    }

    function swap() internal {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        (bool success, ) = DYM_ADDRESS.call(abi.encodeWithSignature("swapETH()"));
        if (!success) revert Interaction_Failed();

        console.log("Swap performed successfully!");
        vm.stopBroadcast();
    }
}

contract CreatePool is Script {
    address private constant DYM_ADDRESS = 0x5f101cdB70bB7081D8AEa072c4E43c6f046A76fE;
    address private constant MEME_COIN = 0x04d2ead8945cF1186Ec4a35AC9eaFe59B109f17d;

    function pool() internal {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        (bool success, ) = DYM_ADDRESS.call(abi.encodeWithSignature("dexMeme(address)", MEME_COIN));
        if (!success) revert Interaction_Failed();

        console.log("Pool created successfully!");
        vm.stopBroadcast();
    }

    function run() external {
        pool();
    }
}
