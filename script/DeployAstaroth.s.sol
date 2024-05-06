// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Asta} from "../src/Asta.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployAsta is Script {
    function run() external returns (Asta, address) {
        uint256 deployerKey = vm.envUint("AST_PRIVATE_KEY");

        uint256 astSupply = 7000;

        vm.startBroadcast(deployerKey);
        Asta asta = new Asta(astSupply);
        address astOwner = vm.addr(deployerKey);
        console.log("Asta Token Deployed: ", address(asta));
        console.log("Asta Token Owner: ", astOwner);
        vm.stopBroadcast();

        return (asta, astOwner);
    }
}
