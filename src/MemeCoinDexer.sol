// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {INonfungiblePositionManager} from "./Interfaces/INonfungiblePositionManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MemeCoinDexer is Ownable {
    /// @dev Errors
    error MCD__SwapETHFailed();
    error MCD__DexMemeFailed();
    error MCD__NotMemeCoinMinterCaller();
    error MCD__NotEnoughTimePassed();

    /// @dev Immutables
    address private immutable i_mcm;

    /// @dev Arrays
    uint[] private s_received_NFTs;
    address[] private s_memeCoinsDexed;

    /// @dev Constants
    address private constant NFT_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52;
    /** @dev Calculation Formula: ((sqrtPriceX96**2)/(2**192))*(10**(token0 decimals - token1 decimals))
     * This  gives us the price of token0 in token1, where token0 -> meme token ERC20, token1 -> WETH
     */
    /// @dev InitialPrice expression: 1 WETH for 100 000 000 ERC20 | 79228162514264337593543950 -> 1 WETH for 1 000 000 ERC20
    uint160 private constant INITIAL_PRICE = 7922816251426433759354395;
    address private constant WETH_ADDRESS = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    uint24 private constant FEE = 3000;

    /// @dev Mappings
    mapping(uint => uint) private s_nftToTimeLeft;

    /// @dev Events
    event FundsReceived(uint indexed amount);
    event Swapped_ETH_For_WETH(uint indexed amount);
    event MemeDexRequestReceived(address indexed coin);
    event MemeDexedSuccessfully(address indexed coin, uint indexed nftId);

    /// @dev Constructor
    constructor(address mcm) Ownable(msg.sender) {
        i_mcm = mcm;
    }

    //////////////////////////////////// @notice MCD External Functions ////////////////////////////////////

    /// @notice Adds possibility to receive funds by this contract, which is required by MFM contract
    receive() external payable {
        emit FundsReceived(msg.value);
    }

    /// @notice Swaps ETH into WETH, creates, initializes and adds liquidity pool for new meme token
    /// @param memeCoinAddress Address of ERC20 meme token minted by MCM contract
    function dexMeme(address memeCoinAddress, uint wethAmount, uint memeCoinAmount) external {
        if (msg.sender != i_mcm) revert MCD__NotMemeCoinMinterCaller();
        emit MemeDexRequestReceived(memeCoinAddress);

        swapETH(wethAmount);

        /// @dev Creating And Initializing Pool
        INonfungiblePositionManager(NFT_POSITION_MANAGER).createAndInitializePoolIfNecessary(memeCoinAddress, WETH_ADDRESS, FEE, INITIAL_PRICE);

        // Approve tokens for the position manager
        IERC20(WETH_ADDRESS).approve(NFT_POSITION_MANAGER, wethAmount);
        IERC20(memeCoinAddress).approve(NFT_POSITION_MANAGER, memeCoinAmount);

        // Add liquidity to the new pool using mint
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: memeCoinAddress,
            token1: WETH_ADDRESS,
            fee: FEE, // Fee tier 0.30%
            tickLower: -887220, // Near 0 price
            tickUpper: 887220, // Extremely high price
            amount0Desired: memeCoinAmount, // Meme token amount sent to manager to provide liquidity
            amount1Desired: wethAmount, // WETH token amount sent to manager to provide liquidity
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this), // Address that will receive NFT representing liquidity pool
            deadline: block.timestamp + 1200 // 20 minutes deadline
        });

        (uint tokenId, , , ) = INonfungiblePositionManager(NFT_POSITION_MANAGER).mint(params);

        s_nftToTimeLeft[tokenId] = (block.timestamp + 52 weeks);
        s_memeCoinsDexed.push(memeCoinAddress);
        /// @dev NonfungiblePositionManager is minting NFT directly to this contract, so we do not need 'IERC721Receiver' with 'onERC721Received()'
        s_received_NFTs.push(tokenId);

        emit MemeDexedSuccessfully(memeCoinAddress, tokenId);
    }

    //////////////////////////////////// @notice MCD Internal Functions ////////////////////////////////////

    /// @notice Swaps ETH for WETH to be able to proceed with 'dexMeme()' function
    function swapETH(uint wethAmount) internal {
        (bool success, ) = WETH_ADDRESS.call{value: wethAmount}(abi.encodeWithSignature("deposit()"));

        if (!success) revert MCD__SwapETHFailed();

        emit Swapped_ETH_For_WETH(IERC20(WETH_ADDRESS).balanceOf(address(this)));
    }

    //////////////////////////////////// @notice DYM Team Functions ////////////////////////////////////

    /// @notice Collects up to a maximum amount of fees owed to a specific position to the recipient
    /// @param tokenId The ID of the NFT for which tokens are being collected
    function collectFees(uint tokenId) external payable {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId, // NFT token Id that represents liquidity pool
            recipient: owner(), // DYM Team wallet address
            amount0Max: type(uint128).max, // ERC20 (type(uint128).max - Gathering all accumulated fees)
            amount1Max: type(uint128).max // WETH (type(uint128).max - Gathering all accumulated fees)
        });

        INonfungiblePositionManager(NFT_POSITION_MANAGER).collect(params);
    }

    ///************************************************************************************************//
    /// @dev THIS FUNCTION IS BLOCKED FOR 1 YEAR TO PREVENT RUG PULL ACTIONS ON NEWLY DEXED MEME COINS //
    ///************************************************************************************************//
    /// @notice Decreases the amount of liquidity in a position and accounts it to the position
    /// @param tokenId The ID of the token for which liquidity is being decreased
    /// @param liquidity The amount by which liquidity will be decreased
    /// @param memeTokenAmount The minimum amount of token0 that should be accounted for the burned liquidity
    /// @param wethAmount The minimum amount of token1 that should be accounted for the burned liquidity
    function decreaseLiquidity(uint tokenId, uint128 liquidity, uint memeTokenAmount, uint wethAmount) external payable onlyOwner {
        if (s_nftToTimeLeft[tokenId] > block.timestamp) revert MCD__NotEnoughTimePassed();

        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId, // The ID of the token for which liquidity was decreased
            liquidity: liquidity, // The amount by which liquidity for the NFT position was decreased
            amount0Min: memeTokenAmount, // The amount of token0 that was accounted for the decrease in liquidity (slippage)
            amount1Min: wethAmount, // The amount of token1 that was accounted for the decrease in liquidity (slippage)
            deadline: block.timestamp + 1200 // 20 minutes deadline
        });

        INonfungiblePositionManager(NFT_POSITION_MANAGER).decreaseLiquidity(params);
    }

    ///************************************************************************************************//
    /// @dev THIS FUNCTION IS BLOCKED FOR 1 YEAR TO PREVENT RUG PULL ACTIONS ON NEWLY DEXED MEME COINS //
    ///************************************************************************************************//
    /// @notice Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens must be collected first.
    /// @param tokenId The ID of the token that is being burned
    function burn(uint tokenId) external payable onlyOwner {
        if (s_nftToTimeLeft[tokenId] > block.timestamp) revert MCD__NotEnoughTimePassed();

        INonfungiblePositionManager(NFT_POSITION_MANAGER).burn(tokenId);
    }

    /// @notice Allows to withdraw all coins pending on contract after pool initialization (Q64.96 price format inaccuracy)
    /// @param coin Address of dexed and burned meme coin or weth
    function gatherCoins(address coin) external onlyOwner {
        IERC20(coin).approve(address(this), IERC20(coin).balanceOf(address(this)));
        IERC20(coin).transferFrom(address(this), owner(), IERC20(coin).balanceOf(address(this)));
    }

    //////////////////////////////////// @notice MCD Getter Functions ////////////////////////////////////

    /// @notice Returns all NFT tokens received from NonfungiblePositionManager
    function getAllTokens() external view returns (uint[] memory) {
        return s_received_NFTs;
    }

    /// @notice Returns all dexed meme coins
    function getDexedCoins() external view returns (address[] memory) {
        return s_memeCoinsDexed;
    }

    /// @notice Returns given token balance for certain user
    function getUserTokenBalance(address user, address token) external view returns (uint) {
        return IERC20(token).balanceOf(user);
    }

    function getConstructorData() external view returns (address) {
        return i_mcm;
    }
}
