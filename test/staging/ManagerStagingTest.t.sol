// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployMemtize} from "../../script/DeployMemtize.s.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";

contract ManagerStagingTest is Test, SkipNetwork {
    DeployMemtize memtizeDeployer;
    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;
    MemeProcessManager memeProcessManager;

    address private OWNER;
    address private USER = makeAddr("user");
    address private USER_TWO = makeAddr("user_two");
    address private USER_THREE = makeAddr("user_three");
    uint256 private constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        memtizeDeployer = new DeployMemtize();

        (memeCoinMinter, memeCoinDexer, memeProcessManager) = memtizeDeployer.run();

        OWNER = memeProcessManager.owner();

        deal(OWNER, STARTING_BALANCE);
        deal(USER, STARTING_BALANCE);
        deal(USER_TWO, STARTING_BALANCE);
        deal(USER_THREE, STARTING_BALANCE);
    }

    function test_CanPerformUpkeepAndHypeMeme() public skipLocalNetwork {
        memeProcessManager.createMeme("Hexur The Memer", "HEX");
        memeProcessManager.createMeme("Osteo Pedro", "PDR");
        memeProcessManager.createMeme("Joke Joker", "JOK");
        memeProcessManager.createMeme("Lama Lou", "LAM");

        vm.prank(USER);
        memeProcessManager.fundMeme{value: 1 ether}(1);

        vm.prank(USER_TWO);
        memeProcessManager.fundMeme{value: 2 ether}(1);

        vm.prank(USER_THREE);
        memeProcessManager.fundMeme{value: 8 ether}(1);

        vm.prank(OWNER);
        memeProcessManager.fundMeme{value: 0.99 ether}(0);

        vm.prank(OWNER);
        memeProcessManager.fundMeme{value: 5 ether}(2);

        vm.warp(block.timestamp + 30 days);
        vm.roll(block.number + 1);

        memeProcessManager.performUpkeep("");

        uint[] memory unprocessed = memeProcessManager.getUnprocessedMemes();
        assertEq(unprocessed.length, 0);

        MemeProcessManager.MemeStatus status;
        (, , , , , , , status) = memeProcessManager.getMemeData(0);
        assert(status == MemeProcessManager.MemeStatus.DEAD);
        (, , , , , , , status) = memeProcessManager.getMemeData(1);
        assert(status == MemeProcessManager.MemeStatus.DEAD);
        (, , , , , , , status) = memeProcessManager.getMemeData(2);
        assert(status == MemeProcessManager.MemeStatus.DEAD);
        (, , , , , , , status) = memeProcessManager.getMemeData(3);
        assert(status == MemeProcessManager.MemeStatus.DEAD);
    }
}
