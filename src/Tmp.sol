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
contract Tmp is IERC721Receiver {
    uint256[] private receivedTokens;

    address private constant NFT_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52; // NFT Position Manager
    uint160 private constant initialPrice = 79228162514264337593543000;

    /// @notice Creates a new Uniswap v3 pool, initializes it and adds liquidity
    /// @param tokenA First token in the pool
    /// @param tokenB Second token in the pool
    /// @param fee The fee tier for the pool (e.g., 3000 for 0.3%)
    /// @param amountA Amount of token A to provide as liquidity
    /// @param amountB Amount of token B to provide as liquidity
    function createPoolAndAddLiquidity(address tokenA, address tokenB, uint24 fee, uint256 amountA, uint256 amountB) external {
        /// @dev Creating And Initializing Pool
        INonfungiblePositionManager(NFT_POSITION_MANAGER).createAndInitializePoolIfNecessary(tokenA, tokenB, fee, initialPrice);

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

        INonfungiblePositionManager(NFT_POSITION_MANAGER).mint(params);
    }

    /// @notice This is needed as NonfungiblePositionManager is releasing NFT once we add liquidity to pool
    function onERC721Received(address /* operator */, address /* from */, uint256 tokenId, bytes memory /* data */) external override returns (bytes4) {
        receivedTokens.push(tokenId);

        // In case we would like to hold that NFT elsewhere
        // IERC721(NFT_ADDRESS).transferFrom(address(this), HACKER, tokenId);

        return this.onERC721Received.selector;
    }

    function getAllTokens() external view returns (uint256[] memory) {
        return receivedTokens;
    }
}
