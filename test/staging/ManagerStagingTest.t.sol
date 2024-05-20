// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";
import {DeployMCD} from "../../script/DeployMCD.s.sol";
import {DeployMPM} from "../../script/DeployMPM.s.sol";

contract ManagerStagingTest is Test, SkipNetwork {
    address private constant TOKEN_ONE = 0x4CA4E161f5A6d2B46D71f0C493fc9325b42A5f5E;
    address private constant TOKEN_TWO = 0x35FbaaadF61e69186B7c7Fc2aF92001aEB338f68;
    address private constant POOL_ONE = 0x76e693a8B9C8825bE804CA4e0bEdF9e4D5b92918;
    address private constant POOL_TWO = 0x0b3cb9Bdb44F436E060687B6f9eBf9cBc3c5a326;

    event MemeCreated(uint indexed id, address indexed creator, string name, string symbol);
    event MemeFunded(uint indexed id, uint indexed value);
    event RefundPerformed(address indexed funder, uint indexed amount);
    event MemeKilled(uint indexed id);
    event MemeHyped(uint indexed id);
    event TransferSuccessfull(uint indexed amount);
    event MemesProcessed(bool indexed performed);

    enum MemeStatus {
        ALIVE,
        DEAD
    }

    DeployMCM mcmDeployer;
    DeployMCD mcdDeployer;
    DeployMPM mpmDeployer;

    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;
    MemeProcessManager memeProcessManager;

    address private OWNER;
    address private USER = makeAddr("user");
    address private USER_TWO = makeAddr("user_two");
    address private USER_THREE = makeAddr("user_three");
    uint256 private constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        mcmDeployer = new DeployMCM();
        mcdDeployer = new DeployMCD();
        mpmDeployer = new DeployMPM();

        memeCoinMinter = mcmDeployer.run();
        memeCoinDexer = mcdDeployer.run(address(memeCoinMinter));
        memeProcessManager = mpmDeployer.run(address(memeCoinMinter), address(memeCoinDexer));

        vm.prank(memeCoinMinter.owner());
        memeCoinMinter.transferOwnership(address(memeProcessManager));

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
