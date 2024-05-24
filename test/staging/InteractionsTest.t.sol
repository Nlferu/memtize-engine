// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDYM} from "../../script/DeployDYM.s.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";
import {Collect, DecreaseLiquidity, Burn, GatherCoins} from "../../script/Interactions.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "../../src/Interfaces/ISwapRouter.sol";
import {IUniswapV3Factory} from "../../src/Interfaces/IUniswapV3Factory.sol";
import {INonfungiblePositionManager} from "../../src/Interfaces/INonfungiblePositionManager.sol";

contract InteractionsTest is Test, SkipNetwork {
    address private constant TOKEN = 0x4CA4E161f5A6d2B46D71f0C493fc9325b42A5f5E;
    address private constant POOL = 0x76e693a8B9C8825bE804CA4e0bEdF9e4D5b92918;
    uint private constant SLIPPAGE = 1;

    HelperConfig helperConfig;
    DeployDYM dymDeployer;
    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;
    MemeProcessManager memeProcessManager;
    Collect collect;
    DecreaseLiquidity decreaseLiquidity;
    Burn burn;
    GatherCoins gatherCoins;

    address nftPositionManager;
    address wrappedNativeToken;
    address swapRouter;

    address private OWNER;
    address private USER = makeAddr("user");
    address private DEVIL = makeAddr("devil");
    uint256 private constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        helperConfig = new HelperConfig();
        dymDeployer = new DeployDYM();

        (nftPositionManager, wrappedNativeToken, swapRouter, ) = helperConfig.activeNetworkConfig();
        (memeCoinMinter, memeCoinDexer, memeProcessManager) = dymDeployer.run();

        OWNER = memeProcessManager.owner();

        deal(OWNER, STARTING_BALANCE);
        deal(USER, STARTING_BALANCE);
        deal(DEVIL, STARTING_BALANCE);

        vm.prank(DEVIL);
        (bool success, ) = wrappedNativeToken.call{value: 50 ether}(abi.encodeWithSignature("deposit()"));
        if (success) console.log("Swap for Devil performed successfully!");

        collect = new Collect();
        decreaseLiquidity = new DecreaseLiquidity();
        burn = new Burn();
        gatherCoins = new GatherCoins();
    }

    function test_Collect() public memesDexed swapsPerformed skipLocalNetwork {
        uint[] memory tokens = memeCoinDexer.getAllTokens();

        collect.run(address(memeCoinDexer), tokens[0]);
    }

    function test_DecreaseLiquidity() public memesDexed skipLocalNetwork {
        vm.warp(block.timestamp + 52 weeks);
        vm.roll(block.number + 1);

        uint[] memory tokens = memeCoinDexer.getAllTokens();

        decreaseLiquidity.run(address(memeCoinDexer), tokens[0], POOL);
    }

    function test_Burn() public memesDexed skipLocalNetwork {
        vm.warp(block.timestamp + 52 weeks);
        vm.roll(block.number + 1);

        uint[] memory tokens = memeCoinDexer.getAllTokens();

        burn.run(address(memeCoinDexer), tokens[0], POOL);
    }

    function test_GatherCoins() public memesDexed skipLocalNetwork {
        gatherCoins.run(address(memeCoinDexer), TOKEN);
    }

    /// @dev Modifiers
    modifier memesDexed() {
        memeProcessManager.createMeme("Hexur The Memer", "HEX");

        vm.prank(USER);
        memeProcessManager.fundMeme{value: 11 ether}(0);

        vm.warp(block.timestamp + 32);
        vm.roll(block.number + 1);

        memeProcessManager.performUpkeep("");

        address[] memory dexedCoins = memeCoinDexer.getDexedCoins();

        TOKEN = dexedCoins[0];
        POOL = IUniswapV3Factory(INonfungiblePositionManager(nftPositionManager).factory()).getPool(TOKEN, wrappedNativeToken, 3000);

        _;
    }

    modifier swapsPerformed() {
        bytes memory path = abi.encodePacked(wrappedNativeToken, uint24(3000), TOKEN);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: DEVIL,
            amountIn: 1 ether,
            amountOutMinimum: 1_000_000
        });

        uint wntBal;
        uint tokenBal;

        wntBal = memeCoinDexer.getUserTokenBalance(DEVIL, wrappedNativeToken);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN);
        console.log("Devil Wrapped Native Token Before: ", wntBal / 1e18);
        console.log("Devil Token Before: ", tokenBal / 1e18);

        vm.startPrank(DEVIL);
        IERC20(wrappedNativeToken).approve(swapRouter, 1 ether);
        ISwapRouter(swapRouter).exactInput(params);
        vm.stopPrank();

        wntBal = memeCoinDexer.getUserTokenBalance(DEVIL, wrappedNativeToken);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN);
        console.log("Devil Wrapped Native Token After: ", wntBal / 1e18);
        console.log("Devil Token After: ", tokenBal / 1e18);

        bytes memory path_two = abi.encodePacked(TOKEN, uint24(3000), wrappedNativeToken);

        ISwapRouter.ExactInputParams memory params_two = ISwapRouter.ExactInputParams({
            path: path_two,
            recipient: DEVIL,
            amountIn: 1_000_000 ether,
            amountOutMinimum: 0.01 ether
        });

        vm.startPrank(DEVIL);
        IERC20(TOKEN).approve(swapRouter, 1_000_000 ether);
        ISwapRouter(swapRouter).exactInput(params_two);
        vm.stopPrank();

        _;
    }
}
