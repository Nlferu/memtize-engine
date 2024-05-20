// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";

contract MemeCoinMinterTest is Test, SkipNetwork {
    function test_MinterConstructor() public skipForkNetwork {
        MemeCoinMinter memeCoinMinter = new MemeCoinMinter();

        assertEq(memeCoinMinter.owner(), address(this));
    }
}
