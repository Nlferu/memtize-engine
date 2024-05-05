// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Interfaces/INonfungiblePositionManager.sol";
import "./Interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/// @notice TODO:
// Block 'DecreaseLiquidity' fn from manager
// Block 'Burn' fn from manager
// Redirect/Manage 'CollectFees' function
// Check 'Repositioning' fn from manager -> block it eventually

// We need to make this contract an ERC721 receiver
// Create mapping that will track time passed after pool creation
contract AmbaTmp is IERC721Receiver {
    uint256[] private receivedTokens;

    // Implementation of the ERC721Receiver function -> TODO!
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    //address public constant FACTORY = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c; // Uniswap v3 Factory
    address public constant NFT_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52; // NFT Position Manager

    INonfungiblePositionManager positionManager = INonfungiblePositionManager(NFT_POSITION_MANAGER);

    //IUniswapV3Factory factory = IUniswapV3Factory(FACTORY);

    /// @notice Creates a new Uniswap v3 pool and adds liquidity
    /// @param tokenA First token in the pool
    /// @param tokenB Second token in the pool
    /// @param fee The fee tier for the pool (e.g., 3000 for 0.3%)
    /// @param amountA Amount of token A to provide as liquidity
    /// @param amountB Amount of token B to provide as liquidity
    function createPoolAndAddLiquidity(address tokenA, address tokenB, uint24 fee, uint256 amountA, uint256 amountB) external {
        // Create new pool
        //address pool = factory.createPool(tokenA, tokenB, fee);

        // Initialize the pool price
        uint160 initialPrice = calculateSqrtPriceX96(amountA, amountB);
        // uint160 initialPrice = uint160(0.001 * (2 ** 96));
        //IUniswapV3Pool(pool).initialize(initialPrice);

        /// @dev Creating And Initializing Pool
        positionManager.createAndInitializePoolIfNecessary(tokenA, tokenB, fee, initialPrice);

        // Approve tokens for the position manager
        IERC20(tokenA).approve(NFT_POSITION_MANAGER, amountA);
        IERC20(tokenB).approve(NFT_POSITION_MANAGER, amountB);

        // Add liquidity to the new pool using mint
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: tokenA,
            token1: tokenB,
            fee: fee,
            tickLower: -887272, // Near 0 price
            tickUpper: 887272, // Extremely high price
            amount0Desired: amountA,
            amount1Desired: amountB,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender, // This address will receive NFT representing liquidity pool
            deadline: block.timestamp + 1200 // 20-minute deadline
        });

        positionManager.mint(params);
    }

    /// @notice Calculates the initial price in Q64.96 format
    /// @param amountA The amount of token A
    /// @param amountB The amount of token B
    /// @return sqrtPriceX96 The initial price for the pool

    /// @dev To be removed after testing
    function calculateSqrtPriceX96(uint256 amountA, uint256 amountB) internal pure returns (uint160) {
        uint256 priceX96 = (amountA * (2 ** 96)) / amountB;
        return uint160(sqrt(priceX96) << 48);
    }

    /// @notice Computes the square root of a number in fixed-point Q64.96 format

    /// @dev To be removed after testing
    function sqrt(uint256 x) internal pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return z;
    }
}
