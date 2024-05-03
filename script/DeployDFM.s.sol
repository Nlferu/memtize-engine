// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DYMFundsManager} from "../src/DYMFundsManager.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployDFM is Script {
    function run(address team, address mcm, address dym) external {
        uint256 deployerKey = vm.envUint("LOCAL_PRIVATE_KEY");

        vm.startBroadcast(deployerKey);
        DYMFundsManager dfm = new DYMFundsManager(team, mcm, dym);
        console.log("Deployed Dex Youe Meme:", address(dfm));
        console.log("Owner: ", dfm.owner());
        vm.stopBroadcast();
    }
}
