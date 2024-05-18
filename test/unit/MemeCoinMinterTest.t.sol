// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {DeployMCD} from "../../script/DeployMCD.s.sol";
import {DeployMPM} from "../../script/DeployMPM.s.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";

contract MemeCoinMinterTest is Test {}
