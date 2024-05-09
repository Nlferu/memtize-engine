// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {INonfungiblePositionManager} from "./Interfaces/INonfungiblePositionManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice TODO:
// Block 'DecreaseLiquidity' fn from manager
// Block 'Burn' fn from manager
// Redirect/Manage 'CollectFees' function
// Check 'Repositioning' fn from manager -> block it eventually

contract DexYourMeme is Ownable, IERC721Receiver {
    /// @dev Errors
    error DYM__SwapETHFailed();
    error DYM__DexMemeFailed();
    error DYM__NotMemeCoinMinterCaller();

    /// @dev Variables
    address private s_team;

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
    /// @dev InitialPrice expression: 0.01 WETH for 1 000 000 AST | 79228162514264337593543950 -> 0.1 WETH for 100 000 AST
    uint160 private constant INITIAL_PRICE = 7922816251426433759354395;
    address private constant WETH_ADDRESS = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    uint24 private constant FEE = 3000;
    uint private constant WETH_AMOUNT = 0.1 * 10 ** 18;
    uint private constant MEME_AMOUNT = 1_000_000 * 10 ** 18;

    /// @dev Events
    event FundsReceived(uint indexed amount);
    event Swapped_ETH_For_WETH(uint indexed amount);
    event MemeDexRequestReceived(address indexed token);
    event MemeDexedSuccessfully(address indexed token);
    event TeamAddressUpdated(address team);

    /// @dev Constructor
    constructor(address team, address mcm) Ownable(msg.sender) {
        s_team = team;
        i_mcm = mcm;
    }

    //////////////////////////////////// @notice DYM External Functions ////////////////////////////////////

    /// @notice Adds possibility to receive funds by this contract, which is required by MFM contract
    receive() external payable {
        emit FundsReceived(msg.value);
    }

    /// @notice Swaps ETH into WETH, creates, initializes and adds liquidity pool for new meme token
    /// @param memeToken Address of ERC20 meme token minted by MCM contract
    function dexMeme(address memeToken) external {
        if (msg.sender != i_mcm) revert DYM__NotMemeCoinMinterCaller();
        emit MemeDexRequestReceived(memeToken);

        swapETH();

        /// @dev Creating And Initializing Pool
        INonfungiblePositionManager(NFT_POSITION_MANAGER).createAndInitializePoolIfNecessary(memeToken, WETH_ADDRESS, FEE, INITIAL_PRICE);

        // Approve tokens for the position manager
        IERC20(WETH_ADDRESS).approve(NFT_POSITION_MANAGER, WETH_AMOUNT);
        IERC20(memeToken).approve(NFT_POSITION_MANAGER, MEME_AMOUNT);

        // Add liquidity to the new pool using mint
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: memeToken,
            token1: WETH_ADDRESS,
            fee: FEE, // Fee tier 0.30%
            tickLower: -887220, // Near 0 price
            tickUpper: 887220, // Extremely high price
            amount0Desired: MEME_AMOUNT, // Meme token amount sent to manager to provide liquidity
            amount1Desired: WETH_AMOUNT, // WETH token amount sent to manager to provide liquidity
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this), // Address that will receive NFT representing liquidity pool
            deadline: block.timestamp + 1200 // 20 minutes deadline
        });

        INonfungiblePositionManager(NFT_POSITION_MANAGER).mint(params);

        s_memeCoinsDexed.push(memeToken);

        emit MemeDexedSuccessfully(memeToken);
    }

    /// @notice This is needed as NonfungiblePositionManager is issuing NFT once we initialize liquidity pool
    function onERC721Received(address /* operator */, address /* from */, uint tokenId, bytes memory /* data */) external override returns (bytes4) {
        s_received_NFTs.push(tokenId);

        return this.onERC721Received.selector;
    }

    //////////////////////////////////// @notice DYM Internal Functions ////////////////////////////////////

    /// @notice Swaps ETH for WETH to be able to proceed with 'dexMeme()' function
    function swapETH() internal {
        (bool success, ) = WETH_ADDRESS.call{value: address(this).balance}(abi.encodeWithSignature("deposit()"));

        if (!success) revert DYM__SwapETHFailed();

        emit Swapped_ETH_For_WETH(IERC20(WETH_ADDRESS).balanceOf(address(this)));
    }

    //////////////////////////////////// @notice DYM Team Functions ////////////////////////////////////

    function collect() external payable onlyOwner {}

    // decreaseLiquidity

    // burn

    /// @notice Updates Dex Your Meme Team wallet address
    function updateTeam(address team) external onlyOwner {
        s_team = team;

        emit TeamAddressUpdated(s_team);
    }

    //////////////////////////////////// @notice DYM Getter Functions ////////////////////////////////////

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
}
