// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";

contract MemeCoinDexerTest is Test, SkipNetwork {
    DeployMCM mcmDeployer;

    HelperConfig helperConfig;
    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;

    address nftPositionManager;
    address wrappedNativeToken;

    function setUp() public {
        helperConfig;
        mcmDeployer = new DeployMCM();
        memeCoinMinter = mcmDeployer.run();
    }

    function test_InitializesDexerCorrectly() public skipForkNetwork {
        memeCoinDexer = new MemeCoinDexer(address(memeCoinMinter), nftPositionManager, wrappedNativeToken);
        (address mcm, address nft, address wnt) = memeCoinDexer.getConstructorData();

        assertEq(address(memeCoinMinter), mcm, "MCM address not initialized correctly");
        assertEq(nftPositionManager, nft, "NFT Manager address not initialized correctly");
        assertEq(wrappedNativeToken, wnt, "Wrapped Native Token address not initialized correctly");
    }

    function test_DexMemeCallableOnlyByMCM() public skipForkNetwork {
        memeCoinDexer = new MemeCoinDexer(address(memeCoinMinter), nftPositionManager, wrappedNativeToken);
        address USER = makeAddr("user");
        deal(USER, 100 ether);

        vm.prank(USER);
        vm.expectRevert(MemeCoinDexer.MCD__NotAllowedCaller.selector);
        memeCoinDexer.dexMeme(USER, 1000, 1000000);
    }
}
