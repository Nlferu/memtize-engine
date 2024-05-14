// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DexYourMeme} from "../src/DexYourMeme.sol";
import {MemeManagementHub} from "../src/MemeManagementHub.sol";
import {MemeCoinMinter} from "../src/MemeCoinMinter.sol";
import {DeployDYM} from "../script/DeployDYM.s.sol";
import {DeployMMH} from "../script/DeployMMH.s.sol";
import {DeployMCM} from "../script/DeployMCM.s.sol";

contract DexYourMemeTest is Test {
    DeployDYM dymDeployer;
    DeployMMH mmhDeployer;
    DeployMCM mcmDeployer;

    DexYourMeme dym;
    MemeManagementHub mmh;
    MemeCoinMinter mcm;

    function setUp() public {
        dymDeployer = new DeployDYM();
        mmhDeployer = new DeployMMH();
        mcmDeployer = new DeployMCM();
    }

    function test_Increment() public {}

    function testFuzz_SetNumber(uint256 x) public {}
}
