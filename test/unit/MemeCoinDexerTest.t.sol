// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";

contract MemeCoinDexerTest is Test {
    DeployMCM mcmDeployer;

    MemeCoinMinter memeCoinMinter;

    function setUp() public {
        mcmDeployer = new DeployMCM();

        memeCoinMinter = mcmDeployer.run();
    }

    function test_InitializesDexerCorrectly() public skipFork {
        MemeCoinDexer mcd = new MemeCoinDexer(address(memeCoinMinter));

        address mcm = mcd.getConstructorData();

        assertEq(address(memeCoinMinter), mcm, "MCM address not initialized correctly");
    }

    function test_DexMemeCallableOnlyByMCM() public skipFork {
        MemeCoinDexer mcd = new MemeCoinDexer(address(memeCoinMinter));
        address USER = makeAddr("user");
        deal(USER, 100 ether);

        vm.prank(USER);
        vm.expectRevert(MemeCoinDexer.MCD__NotMemeCoinMinterCaller.selector);
        mcd.dexMeme(USER, 1000, 1000000);
    }

    function test_CanThrowErrorWhenSwapFails() public skipFork {
        MemeCoinDexer mcd = new MemeCoinDexer(address(memeCoinMinter));

        deal(address(mcd), 100 ether);

        InvalidRecipient mockContract;

        // Deploy the MockContract and assign it to a WETH address
        address mockAddress = address(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
        vm.etch(mockAddress, type(InvalidRecipient).creationCode);

        // Initialize the mockContract instance with the WETH address
        mockContract = InvalidRecipient(mockAddress);

        vm.prank(address(memeCoinMinter));
        vm.expectRevert(MemeCoinDexer.MCD__SwapETHFailed.selector);
        mcd.dexMeme(address(memeCoinMinter), 1000, 1000000);
    }

    modifier skipFork() {
        /// @dev Comment below 'if' statement line to perform full coverage test with command 'make testForkSepoliaCoverage'
        // if (block.chainid != 31337) return;

        _;
    }
}
