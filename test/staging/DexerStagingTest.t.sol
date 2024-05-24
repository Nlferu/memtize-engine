// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDYM} from "../../script/DeployDYM.s.sol";
import {MemeCoinMinter} from "../../src/MemeCoinMinter.sol";
import {MemeCoinDexer} from "../../src/MemeCoinDexer.sol";
import {MemeProcessManager} from "../../src/MemeProcessManager.sol";
import {InvalidRecipient} from "../mock/InvalidRecipient.sol";
import {SkipNetwork} from "../mods/SkipNetwork.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "../../src/Interfaces/ISwapRouter.sol";
import {IUniswapV3Pool} from "../../src/Interfaces/IUniswapV3Pool.sol";
import {IUniswapV3Factory} from "../../src/Interfaces/IUniswapV3Factory.sol";
import {INonfungiblePositionManager} from "../../src/Interfaces/INonfungiblePositionManager.sol";

contract DexerStagingTest is Test, SkipNetwork {
    address private TOKEN_ONE;
    address private TOKEN_TWO;
    address private POOL_ONE;
    address private POOL_TWO;
    uint private constant SLIPPAGE = 1;

    HelperConfig helperConfig;
    DeployDYM dymDeployer;
    MemeCoinMinter memeCoinMinter;
    MemeCoinDexer memeCoinDexer;
    MemeProcessManager memeProcessManager;

    address nftPositionManager;
    address wrappedNativeToken;
    address swapRouter;

    address private OWNER;
    address private USER = makeAddr("user");
    address private DEVIL = makeAddr("devil");
    address private USER_TWO = makeAddr("user_two");
    address private USER_THREE = makeAddr("user_three");
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
        deal(USER_TWO, STARTING_BALANCE);
        deal(USER_THREE, STARTING_BALANCE);

        vm.prank(DEVIL);
        (bool success, ) = wrappedNativeToken.call{value: 50 ether}(abi.encodeWithSignature("deposit()"));
        if (success) console.log("Swap for Devil performed successfully!");

        /// @dev Dexing Memes
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

        address[] memory dexedCoins = memeCoinDexer.getDexedCoins();
        TOKEN_ONE = dexedCoins[0];
        TOKEN_TWO = dexedCoins[1];
        POOL_ONE = IUniswapV3Factory(INonfungiblePositionManager(nftPositionManager).factory()).getPool(TOKEN_ONE, wrappedNativeToken, 3000);
        POOL_TWO = IUniswapV3Factory(INonfungiblePositionManager(nftPositionManager).factory()).getPool(TOKEN_TWO, wrappedNativeToken, 3000);
    }

    function test_CanSetProperBalancesAfterHypeMeme() public skipLocalNetwork {
        uint dexerBalance = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), wrappedNativeToken);
        uint dexerErc1 = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), TOKEN_ONE);
        uint dexerErc2 = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), TOKEN_TWO);

        assertEq(dexerBalance, 0);
        /// @dev Coins left from Q64.96 inaccurate calculation (Fewer than 1 coin out of 100,000,000 crafted coins (almost 1 coin per 1 ETH) is left in the contract)
        assertEq(dexerErc1 / 1e18, 10);
        assertEq(dexerErc2 / 1e18, 4);

        uint pool1wnt = memeCoinDexer.getUserTokenBalance(POOL_ONE, wrappedNativeToken);
        uint pool1erc = memeCoinDexer.getUserTokenBalance(POOL_ONE, TOKEN_ONE);
        uint pool2wnt = memeCoinDexer.getUserTokenBalance(POOL_TWO, wrappedNativeToken);
        uint pool2erc = memeCoinDexer.getUserTokenBalance(POOL_TWO, TOKEN_TWO);

        assertEq(pool1wnt / 1e18, 11);
        assertEq(pool1erc / 1e18, 1_100_000_000);
        assertEq(pool2wnt / 1e18, 5);
        assertEq(pool2erc / 1e18, 500_000_000);

        uint[] memory tokens = memeCoinDexer.getAllTokens();
        address[] memory dexedMemes = memeCoinDexer.getDexedCoins();

        assertEq(tokens.length, 2);
        assertEq(dexedMemes.length, 2);
    }

    function test_CanCollect() public swapsPerformed skipLocalNetwork {
        uint feeGrowthGlobal0X128 = IUniswapV3Pool(POOL_ONE).feeGrowthGlobal0X128();
        uint feeGrowthGlobal1X128 = IUniswapV3Pool(POOL_ONE).feeGrowthGlobal1X128();
        uint128 liquidity = IUniswapV3Pool(POOL_ONE).liquidity();

        /// @dev Precalculated fees feeGrowthInside0LastX128/feeGrowthInside1LastX128 -> this will be 0
        // uint128 feesOwed0 = (((feeGrowthGlobal0X128 - feeGrowthInside0LastX128) * liquidity) / 2**128);
        // uint128 feesOwed1 = (((feeGrowthGlobal1X128 - feeGrowthInside1LastX128) * liquidity) / 2**128);
        uint128 feesOwed0 = uint128((feeGrowthGlobal0X128 * liquidity) / 2 ** 128);
        uint256 feesOwed1 = uint128((feeGrowthGlobal1X128 * liquidity) / 2 ** 128);
        console.log("Gathered Fees ERC20: ", feesOwed0);
        console.log("Gathered Fees Wrapped Native Token: ", feesOwed1);

        uint ownerErc20Balance = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), TOKEN_ONE);
        uint ownerWntBalance = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), wrappedNativeToken);

        uint[] memory tokens = memeCoinDexer.getAllTokens();

        vm.prank(memeCoinDexer.owner());
        memeCoinDexer.collect(tokens[0]);

        uint ownerErc20BalanceAfter = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), TOKEN_ONE);
        uint ownerWntBalanceAfter = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), wrappedNativeToken);

        assertEq(ownerErc20BalanceAfter, ownerErc20Balance + feesOwed0);
        assertEq(ownerWntBalanceAfter, ownerWntBalance + feesOwed1);
    }

    function test_CanDecreaseLiquidityAfterTimePass() public skipLocalNetwork {
        uint[] memory tokens = memeCoinDexer.getAllTokens();
        memeCoinDexer.collect(tokens[0]);
        uint feeGrowthGlobal0X128 = IUniswapV3Pool(POOL_ONE).feeGrowthGlobal0X128();
        uint feeGrowthGlobal1X128 = IUniswapV3Pool(POOL_ONE).feeGrowthGlobal1X128();
        uint128 liquidity = IUniswapV3Pool(POOL_ONE).liquidity();

        vm.prank(memeCoinDexer.owner());
        vm.expectRevert(MemeCoinDexer.MCD__NotEnoughTimePassed.selector);
        memeCoinDexer.decreaseLiquidity(tokens[0], liquidity, SLIPPAGE, SLIPPAGE);

        vm.warp(block.timestamp + 52 weeks);
        vm.roll(block.number + 1);

        uint ownerErc20Balance = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), TOKEN_ONE);
        uint ownerWntBalance = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), wrappedNativeToken);

        vm.prank(memeCoinDexer.owner());
        memeCoinDexer.decreaseLiquidity(tokens[0], liquidity, SLIPPAGE, SLIPPAGE);

        /// @dev After the decrease in liquidity we have to collect liquidated tokens
        uint128 feesOwed0 = uint128((feeGrowthGlobal0X128 * liquidity) / 2 ** 128);
        uint256 feesOwed1 = uint128((feeGrowthGlobal1X128 * liquidity) / 2 ** 128);

        memeCoinDexer.collect(tokens[0]);

        uint ownerErc20BalanceAfter = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), TOKEN_ONE);
        uint ownerWntBalanceAfter = memeCoinDexer.getUserTokenBalance(memeCoinDexer.owner(), wrappedNativeToken);

        /// @dev Value: 1_100_000_000_000_000_597_886_004_026 has been taken from emit that communicated liquidity increase
        assertEq(ownerErc20BalanceAfter, ownerErc20Balance + 1_100_000_000_000_000_597_886_004_026 + feesOwed0 - SLIPPAGE);
        assertEq(ownerWntBalanceAfter, ownerWntBalance + 11 ether + feesOwed1 - SLIPPAGE);
    }

    function test_CanBurnAfterTimePass() public skipLocalNetwork {
        uint[] memory tokens = memeCoinDexer.getAllTokens();
        uint128 liquidity = IUniswapV3Pool(POOL_ONE).liquidity();

        vm.warp(block.timestamp + 52 weeks);
        vm.roll(block.number + 1);

        vm.prank(memeCoinDexer.owner());
        memeCoinDexer.decreaseLiquidity(tokens[0], liquidity, SLIPPAGE, SLIPPAGE);
        memeCoinDexer.collect(tokens[0]);

        vm.warp(block.timestamp - 1 weeks);
        vm.roll(block.number + 1);

        vm.prank(memeCoinDexer.owner());
        vm.expectRevert(MemeCoinDexer.MCD__NotEnoughTimePassed.selector);
        memeCoinDexer.burn(tokens[0]);

        vm.warp(block.timestamp + 1 weeks);
        vm.roll(block.number + 1);

        vm.prank(memeCoinDexer.owner());
        memeCoinDexer.burn(tokens[0]);
    }

    function test_CanGatherCoins() public skipLocalNetwork {
        vm.startPrank(memeCoinDexer.owner());
        memeCoinDexer.gatherCoins(TOKEN_ONE);
        memeCoinDexer.gatherCoins(TOKEN_TWO);
        vm.stopPrank();

        uint balance_one = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), TOKEN_ONE);
        uint balance_two = memeCoinDexer.getUserTokenBalance(address(memeCoinDexer), TOKEN_ONE);

        assertEq(balance_one, 0);
        assertEq(balance_two, 0);
    }

    function test_CanThrowErrorWhenSwapFails() public skipLocalNetwork {
        deal(address(memeCoinDexer), 100 ether);

        InvalidRecipient mockContract;

        // Deploy the MockContract and assign it to a Wrapped Native Token address
        vm.etch(wrappedNativeToken, type(InvalidRecipient).creationCode);

        // Initialize the mockContract instance with the Wrapped Native Token address
        mockContract = InvalidRecipient(wrappedNativeToken);

        vm.prank(address(memeCoinMinter));
        vm.expectRevert(MemeCoinDexer.MCD__SwapETHFailed.selector);
        memeCoinDexer.dexMeme(address(memeCoinMinter), 1000, 1000000);
    }

    /// @dev Modifiers
    modifier swapsPerformed() {
        (, int24 currentTick, , , , , ) = IUniswapV3Pool(POOL_ONE).slot0();
        bool isInRangee = (currentTick >= -887220 && currentTick <= 887220);
        console.log("Is Trade In Range:", isInRangee);

        bytes memory path = abi.encodePacked(wrappedNativeToken, uint24(3000), TOKEN_ONE);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: DEVIL,
            amountIn: 1 ether,
            amountOutMinimum: 1_000_000
        });

        uint wntBal;
        uint tokenBal;

        wntBal = memeCoinDexer.getUserTokenBalance(DEVIL, wrappedNativeToken);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN_ONE);
        console.log("Devil Wrapped Native Token Before: ", wntBal / 1e18);
        console.log("Devil Token Before: ", tokenBal / 1e18);

        vm.startPrank(DEVIL);
        IERC20(wrappedNativeToken).approve(swapRouter, 1 ether);
        ISwapRouter(swapRouter).exactInput(params);
        vm.stopPrank();

        wntBal = memeCoinDexer.getUserTokenBalance(DEVIL, wrappedNativeToken);
        tokenBal = memeCoinDexer.getUserTokenBalance(DEVIL, TOKEN_ONE);
        console.log("Devil Wrapped Native Token After: ", wntBal / 1e18);
        console.log("Devil Token After: ", tokenBal / 1e18);

        bytes memory path_two = abi.encodePacked(TOKEN_ONE, uint24(3000), wrappedNativeToken);

        ISwapRouter.ExactInputParams memory params_two = ISwapRouter.ExactInputParams({
            path: path_two,
            recipient: DEVIL,
            amountIn: 1_000_000 ether,
            amountOutMinimum: 0.01 ether
        });

        vm.startPrank(DEVIL);
        IERC20(TOKEN_ONE).approve(swapRouter, 1_000_000 ether);
        ISwapRouter(swapRouter).exactInput(params_two);
        vm.stopPrank();

        _;
    }
}
