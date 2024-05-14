// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DexYourMeme} from "../src/DexYourMeme.sol";
import {MemeProcessManager} from "../src/MemeProcessManager.sol";
import {MemeCoinMinter} from "../src/MemeCoinMinter.sol";
import {DeployDYM} from "../script/DeployDYM.s.sol";
import {DeployMPM} from "../script/DeployMPM.s.sol";
import {DeployMCM} from "../script/DeployMCM.s.sol";

contract DexYourMemeTest is Test {
    DeployDYM dymDeployer;
    DeployMPM mpmDeployer;
    DeployMCM mcmDeployer;

    DexYourMeme dym;
    MemeProcessManager mpm;
    MemeCoinMinter mcm;

    function setUp() public {
        dymDeployer = new DeployDYM();
        mpmDeployer = new DeployMPM();
        mcmDeployer = new DeployMCM();
    }

    function test_Increment() public {}

    function testFuzz_SetNumber(uint256 x) public {}
}
