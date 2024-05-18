// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {ISwapRouter} from "../../src/Interfaces/ISwapRouter.sol";
import {DeployMCM} from "../../script/DeployMCM.s.sol";
import {DeployMCD} from "../../script/DeployMCD.s.sol";
import {DeployMPM} from "../../script/DeployMPM.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexerStagingTest is Test {
    address private constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
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

    uint private constant INTERVAL = 30;

    DeployMCM mcmDeployer;
    DeployMCD mcdDeployer;
    DeployMPM mpmDeployer;

    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;
    MemeProcessManager memeProcessManager;

    address private OWNER;
    address private USER = makeAddr("user");
    address private DEVIL = makeAddr("devil");
    address private USER_TWO = makeAddr("user_two");
    address private USER_THREE = makeAddr("user_three");
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
        deal(DEVIL, STARTING_BALANCE);
        deal(USER, STARTING_BALANCE);
        deal(USER_TWO, STARTING_BALANCE);
        deal(USER_THREE, STARTING_BALANCE);

        vm.prank(DEVIL);
        (bool success, ) = WETH.call{value: 50 ether}(abi.encodeWithSignature("deposit()"));
        if (success) console.log("Swap for Devil performed successfully!");
    }

    function test_CanSetProperBalancesAfterHypeMeme() public memesDexedTimePassed onlyOnForkNetwork {
        uint dexerBalance = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), WETH);
        uint dexerErc1 = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), TOKEN_ONE);
        uint dexerErc2 = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), TOKEN_TWO);

        assertEq(dexerBalance, 0);
        /// @dev Coins left from Q64.96 inaccurate calculation (Fewer than 1 coin out of 100,000,000 crafted coins (almost 1 coin per 1 ETH) is left in the contract)
        assertEq(dexerErc1 / 1e18, 10);
        assertEq(dexerErc2 / 1e18, 4);

        uint pool1weth = memeCoinDexer.getUserTokenBalance(POOL_ONE, WETH);
        uint pool1erc = memeCoinDexer.getUserTokenBalance(POOL_ONE, TOKEN_ONE);
        uint pool2weth = memeCoinDexer.getUserTokenBalance(POOL_TWO, WETH);
        uint pool2erc = memeCoinDexer.getUserTokenBalance(POOL_TWO, TOKEN_TWO);

        assertEq(pool1weth / 1e18, 11);
        assertEq(pool1erc / 1e18, 1_100_000_000);
        assertEq(pool2weth / 1e18, 5);
        assertEq(pool2erc / 1e18, 500_000_000);

        uint[] memory tokens = memeCoinDexer.getAllTokens();
        address[] memory dexedMemes = memeCoinDexer.getDexedCoins();

        assertEq(tokens.length, 2);
        assertEq(dexedMemes.length, 2);
    }

    function test_CanCollectFees() public memesDexedTimePassed onlyOnForkNetwork {
        uint[] memory tokens = memeCoinDexer.getAllTokens();

        /// @dev Sepolia
        address swapRouter02 = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;

        bytes memory path = abi.encodePacked(WETH, uint24(3000), TOKEN_ONE);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: DEVIL,
            amountIn: 1 ether,
            amountOutMinimum: 1_000_000
        });

        uint wethBal;
        uint tokenBal;

        wethBal = memeCoinDexer.getUserTokenBalance(DEVIL, WETH);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN_ONE);
        console.log("Devil WETH Before: ", wethBal / 1e18);
        console.log("Devil Token Before: ", tokenBal / 1e18);

        vm.startPrank(DEVIL);
        IERC20(WETH).approve(swapRouter02, 1 ether);
        ISwapRouter(swapRouter02).exactInput(params);
        vm.stopPrank();

        wethBal = memeCoinDexer.getUserTokenBalance(DEVIL, WETH);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN_ONE);
        console.log("Devil WETH After: ", wethBal / 1e18);
        console.log("Devil Token After: ", tokenBal / 1e18);

        bytes memory path_two = abi.encodePacked(TOKEN_ONE, uint24(3000), WETH);

        ISwapRouter.ExactInputParams memory params_two = ISwapRouter.ExactInputParams({
            path: path_two,
            recipient: DEVIL,
            amountIn: 1_000_000 ether,
            amountOutMinimum: 0.01 ether
        });

        vm.startPrank(DEVIL);
        IERC20(TOKEN_ONE).approve(swapRouter02, 1_000_000 ether);
        ISwapRouter(swapRouter02).exactInput(params_two);
        vm.stopPrank();

        address[] memory coins = memeCoinDexer.getDexedCoins();

        console.log("Token One: ", tokens[0]);
        console.log("Token Two: ", tokens[1]);
        console.log("Coins Dexed: ", coins[0]);
        console.log("TOKEN_ONE: ", TOKEN_ONE);
        console.log("Coins Dexed 2nd: ", coins[1]);

        vm.prank(memeCoinDexer.owner());
        memeCoinDexer.collectFees(tokens[0]);
    }

    modifier memesDexedTimePassed() {
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

        vm.warp(block.timestamp + 32);
        vm.roll(block.number + 1);

        memeProcessManager.performUpkeep("");

        _;
    }

    modifier onlyOnForkNetwork() {
        if (block.chainid == 31337) return;

        _;
    }
}
