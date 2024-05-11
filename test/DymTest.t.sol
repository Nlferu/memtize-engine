// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DexYourMeme} from "../src/DexYourMeme.sol";
import {DeployDYM} from "../script/DeployDYM.s.sol";

contract CounterTest is Test {
    DeployDYM dymDeployer;
    DexYourMeme dym;

    function setUp() public {}

    function test_Increment() public {}

    function testFuzz_SetNumber(uint256 x) public {}
}
