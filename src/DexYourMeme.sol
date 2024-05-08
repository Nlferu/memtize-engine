// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/// @notice TODO:
// Block 'DecreaseLiquidity' fn from manager
// Block 'Burn' fn from manager
// Redirect/Manage 'CollectFees' function
// Check 'Repositioning' fn from manager -> block it eventually

contract DexYourMeme is IERC721Receiver {
    /// @dev Errors
    error DYM__SwapETHFailed();
    error DYM__DexMemeFailed();
    error DYM__NotMemeCoinMinterCaller();

    /// @dev Immutables
    address private immutable i_mcm;

    /// @dev Arrays
    uint256[] private s_received_NFTs;
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
    uint256 private constant WETH_AMOUNT = 0.1 * 10 ** 18;
    uint256 private constant MEME_AMOUNT = 1_000_000 * 10 ** 18;

    /// @dev Events
    event FundsReceived(uint indexed amount);
    event Swapped_ETH_For_WETH(uint indexed amount);
    event MemeDexedSuccessfully(address indexed token);

    /// @dev Constructor
    constructor(address mcm) {
        i_mcm = mcm;
    }

    /// @notice Adds possibility to receive funds by this contract, which is required by MFM contract
    receive() external payable {
        emit FundsReceived(msg.value);
    }

    /// @dev This to be changed to internal and called by Chainlink keepers
    function dexMeme(address memeToken) external {
        if (msg.sender != i_mcm) revert DYM__NotMemeCoinMinterCaller();

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
            fee: FEE,
            tickLower: -887220, // Near 0 price
            tickUpper: 887220, // Extremely high price
            amount0Desired: MEME_AMOUNT, // 76,709.999999999999999615 -> input: 76710000000000000000000 | 1 000 000 000
            amount1Desired: WETH_AMOUNT, // 0.49999999999999999999999 -> input: 500000000000000000 | 1 000 000 000
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this), // This address will receive NFT representing liquidity pool
            deadline: block.timestamp + 1200 // 20 minutes deadline
        });

        INonfungiblePositionManager(NFT_POSITION_MANAGER).mint(params);

        emit MemeDexedSuccessfully(memeToken);
    }

    /// @notice Swaps ETH for WETH to be able to proceed with 'dexMeme()' function
    function swapETH() internal {
        (bool success, ) = WETH_ADDRESS.call{value: address(this).balance}(abi.encodeWithSignature("deposit()"));

        if (!success) revert DYM__SwapETHFailed();

        emit Swapped_ETH_For_WETH(IERC20(WETH_ADDRESS).balanceOf(address(this)));
    }

    /// @notice This is needed as NonfungiblePositionManager is issuing NFT once we initialize liquidity pool
    function onERC721Received(address /* operator */, address /* from */, uint256 tokenId, bytes memory /* data */) external override returns (bytes4) {
        s_received_NFTs.push(tokenId);

        // In case we would like to hold that NFT elsewhere
        // IERC721(NFT_ADDRESS).transferFrom(address(this), HACKER, tokenId);

        return this.onERC721Received.selector;
    }

    function getAllTokens() external view returns (uint256[] memory) {
        return s_received_NFTs;
    }

    /// @notice Returns given token balance for certain user
    function getUserTokenBalance(address user, address token) external view returns (uint) {
        return IERC20(token).balanceOf(user);
    }
}
