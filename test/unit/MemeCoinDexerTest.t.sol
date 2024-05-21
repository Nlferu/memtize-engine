// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";
import {DeployMCD} from "../../script/DeployMCD.s.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";

contract MemeCoinDexerTest is Test, SkipNetwork {
    DeployMCM mcmDeployer;
    DeployMCD mcdDeployer;

    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;

    address nftPositionManager;
    address wrappedNativeToken;

    function setUp() public {
        mcmDeployer = new DeployMCM();
        mcdDeployer = new DeployMCD();

        memeCoinMinter = mcmDeployer.run();
        memeCoinDexer = mcdDeployer.run(address(memeCoinMinter));
    }

    function test_InitializesDexerCorrectly() public skipForkNetwork {
        memeCoinDexer = new MemeCoinDexer(address(memeCoinMinter), nftPositionManager, wrappedNativeToken);
        (address mcm, address nft, address wnt) = memeCoinDexer.getConstructorData();

        assertEq(address(memeCoinMinter), mcm, "MCM address not initialized correctly");
        assertEq(nftPositionManager, nft, "NFT Manager address not initialized correctly");
        assertEq(wrappedNativeToken, wnt, "Wrapped Native Token address not initialized correctly");
    }

    function test_DexMemeCallableOnlyByMCM() public skipForkNetwork {
        address USER = makeAddr("user");
        deal(USER, 100 ether);

        vm.prank(USER);
        vm.expectRevert(MemeCoinDexer.MCD__NotAllowedCaller.selector);
        memeCoinDexer.dexMeme(USER, 1000, 1000000);
    }
}
