// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DexYourMeme} from "../src/DexYourMeme.sol";
import {Script, console} from "forge-std/Script.sol";

error Interaction_Failed();

interface IERC20 {
    /** @notice Allows to check token balance for certain address */
    function balanceOf(address account) external view returns (uint);
}

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

contract CheckTokenBalance is Script {
    address private constant WETH_ADDRESS = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;

    function checkBalance(address token) internal view returns (uint) {
        return IERC20(token).balanceOf(address(this));
    }

    function run() external view returns (uint) {
        uint256 balance = checkBalance(WETH_ADDRESS);

        console.log("Balance Of WETH: ", balance);

        return balance;
    }
}
