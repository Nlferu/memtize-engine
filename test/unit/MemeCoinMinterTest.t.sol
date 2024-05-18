// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";

contract MemeCoinMinterTest is Test {
    function test_MinterConstructor() public skipFork {
        MemeCoinMinter memeCoinMinter = new MemeCoinMinter();

        assertEq(memeCoinMinter.owner(), address(this));
    }

    modifier skipFork() {
        /// @dev Comment below 'if' statement line to perform full coverage test with command 'make testForkSepoliaCoverage'
        // if (block.chainid != 31337) return;

        _;
    }
}
