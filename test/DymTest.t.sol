// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DexYourMeme} from "../src/DexYourMeme.sol";
import {DYMFundsManager} from "../src/DYMFundsManager.sol";
import {MemeCoinMinter} from "../src/MemeCoinMinter.sol";
import {DeployDYM} from "../script/DeployDYM.s.sol";
import {DeployDFM} from "../script/DeployDFM.s.sol";
import {DeployMCM} from "../script/DeployMCM.s.sol";

contract CounterTest is Test {
    DeployDYM dymDeployer;
    DeployDFM dfmDeployer;
    DeployMCM mcmDeployer;

    DexYourMeme dym;
    DYMFundsManager dfm;
    MemeCoinMinter mcm;

    function setUp() public {
        dymDeployer = new DeployDYM();
        dfmDeployer = new DeployDFM();
        mcmDeployer = new DeployMCM();
    }

    function test_Increment() public {}

    function testFuzz_SetNumber(uint256 x) public {}
}
