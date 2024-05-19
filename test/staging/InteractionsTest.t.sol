// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {Collect, DecreaseLiquidity, Burn, GatherCoins} from "../../script/Interactions.s.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";
import {DeployMCD} from "../../script/DeployMCD.s.sol";
import {DeployMPM} from "../../script/DeployMPM.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "../../src/Interfaces/ISwapRouter.sol";
import {IUniswapV3Pool} from "../../src/Interfaces/IUniswapV3Pool.sol";

contract InteractionsTest is Test {
    address private constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    address private constant TOKEN = 0x4CA4E161f5A6d2B46D71f0C493fc9325b42A5f5E;
    address private constant POOL = 0x76e693a8B9C8825bE804CA4e0bEdF9e4D5b92918;
    uint private constant SLIPPAGE = 1;
    uint private constant INTERVAL = 30;

    DeployMCM mcmDeployer;
    DeployMCD mcdDeployer;
    DeployMPM mpmDeployer;

    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;
    MemeProcessManager memeProcessManager;
    Collect collect;
    DecreaseLiquidity decreaseLiquidity;
    Burn burn;
    GatherCoins gatherCoins;

    address private OWNER;
    address private USER = makeAddr("user");
    address private DEVIL = makeAddr("devil");
    uint256 private constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        mcmDeployer = new DeployMCM();
        mcdDeployer = new DeployMCD();
        mpmDeployer = new DeployMPM();

        memeCoinMinter = mcmDeployer.run();
        memeCoinDexer = mcdDeployer.run(address(memeCoinMinter));
        memeProcessManager = mpmDeployer.run(address(memeCoinMinter), address(memeCoinDexer), INTERVAL);

        vm.prank(memeCoinMinter.owner());
        memeCoinMinter.transferOwnership(address(memeProcessManager));

        OWNER = memeProcessManager.owner();

        deal(OWNER, STARTING_BALANCE);
        deal(USER, STARTING_BALANCE);
        deal(DEVIL, STARTING_BALANCE);

        vm.prank(DEVIL);
        (bool success, ) = WETH.call{value: 50 ether}(abi.encodeWithSignature("deposit()"));
        if (success) console.log("Swap for Devil performed successfully!");

        collect = new Collect();
        decreaseLiquidity = new DecreaseLiquidity();
        burn = new Burn();
        gatherCoins = new GatherCoins();
    }

    function test_Collect() public memesDexedTimePassed swapPerformedToAccumulateFees onlyOnForkNetwork {
        uint[] memory tokens = memeCoinDexer.getAllTokens();

        collect.run(address(memeCoinDexer), tokens[0]);
    }

    function test_DecreaseLiquidity() public memesDexedTimePassed onlyOnForkNetwork {
        vm.warp(block.timestamp + 52 weeks);
        vm.roll(block.number + 1);

        uint[] memory tokens = memeCoinDexer.getAllTokens();

        decreaseLiquidity.run(address(memeCoinDexer), tokens[0], POOL);
    }

    function test_Burn() public memesDexedTimePassed onlyOnForkNetwork {
        vm.warp(block.timestamp + 52 weeks);
        vm.roll(block.number + 1);

        uint[] memory tokens = memeCoinDexer.getAllTokens();

        decreaseLiquidity.run(address(memeCoinDexer), tokens[0], POOL);
        collect.run(address(memeCoinDexer), tokens[0]);

        vm.warp(block.timestamp + 1 weeks);
        vm.roll(block.number + 1);

        burn.run(address(memeCoinDexer), tokens[0]);
    }

    function test_GatherCoins() public memesDexedTimePassed onlyOnForkNetwork {
        gatherCoins.run(address(memeCoinDexer), TOKEN);
    }

    modifier memesDexedTimePassed() {
        memeProcessManager.createMeme("Hexur The Memer", "HEX");

        vm.prank(USER);
        memeProcessManager.fundMeme{value: 11 ether}(0);

        vm.warp(block.timestamp + 32);
        vm.roll(block.number + 1);

        memeProcessManager.performUpkeep("");

        _;
    }

    modifier swapPerformedToAccumulateFees() {
        /// @dev Sepolia
        address swapRouter02 = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;

        bytes memory path = abi.encodePacked(WETH, uint24(3000), TOKEN);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: DEVIL,
            amountIn: 1 ether,
            amountOutMinimum: 1_000_000
        });

        uint wethBal;
        uint tokenBal;

        wethBal = memeCoinDexer.getUserTokenBalance(DEVIL, WETH);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN);
        console.log("Devil WETH Before: ", wethBal / 1e18);
        console.log("Devil Token Before: ", tokenBal / 1e18);

        vm.startPrank(DEVIL);
        IERC20(WETH).approve(swapRouter02, 1 ether);
        ISwapRouter(swapRouter02).exactInput(params);
        vm.stopPrank();

        wethBal = memeCoinDexer.getUserTokenBalance(DEVIL, WETH);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN);
        console.log("Devil WETH After: ", wethBal / 1e18);
        console.log("Devil Token After: ", tokenBal / 1e18);

        bytes memory path_two = abi.encodePacked(TOKEN, uint24(3000), WETH);

        ISwapRouter.ExactInputParams memory params_two = ISwapRouter.ExactInputParams({
            path: path_two,
            recipient: DEVIL,
            amountIn: 1_000_000 ether,
            amountOutMinimum: 0.01 ether
        });

        vm.startPrank(DEVIL);
        IERC20(TOKEN).approve(swapRouter02, 1_000_000 ether);
        ISwapRouter(swapRouter02).exactInput(params_two);
        vm.stopPrank();

        _;
    }

    modifier onlyOnForkNetwork() {
        if (block.chainid == 31337) return;

        _;
    }
}
