// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20 {
    /** @notice Allows to transfer tokens from any address to any recipient */
    function transferFrom(address from, address to, uint amount) external returns (bool);

    /** @notice Allows to transfer tokens from this address to recipient */
    function transfer(address to, uint amount) external returns (bool);

    /** @notice Allows to check token balance for certain address */
    function balanceOf(address account) external view returns (uint);
}

interface IUniswapV3Pool {
    function mint(address recipient, int24 tickLower, int24 tickUpper, uint128 amount, bytes calldata data) external returns (uint256 amount0, uint256 amount1);
}

contract DexYourMeme {
    error DYM_SwapETHFailed();
    error DYM__DexMemeFailed();

    event FundsReceived(uint indexed amount);
    event SwappedWETH(uint indexed amount);
    event MemeDexedSuccessfully(address indexed token, address indexed pool);

    address private constant UNISWAP_FACTORY = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;
    address private constant WETH_ADDRESS = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    uint24 private constant FEE = 3000;

    address pool;

    function dexMeme(address memeToken) external {
        // swapETH(); -> commented for testing purposes

        (bool success, bytes memory data) = UNISWAP_FACTORY.call(abi.encodeWithSignature("createPool(address,address,uint24)", WETH_ADDRESS, memeToken, FEE));

        if (!success) revert DYM__DexMemeFailed();
        address poolAddress = abi.decode(data, (address));

        pool = poolAddress;

        emit MemeDexedSuccessfully(memeToken, poolAddress);
    }

    /** @notice Swaps ETH for WETH to be able to proceed with 'dexMeme()' function */
    // This has to be changed to internal after testing
    function swapETH() external {
        (bool success, ) = WETH_ADDRESS.call{value: address(this).balance}(abi.encodeWithSignature("deposit()"));

        if (!success) revert DYM_SwapETHFailed();

        emit SwappedWETH(IERC20(WETH_ADDRESS).balanceOf(address(this)));
    }

    function addLiquidity(address token0, address token1, uint24 fee, int24 tickLower, int24 tickUpper, uint128 liquidityAmount) external {
        // Token approvals @TODO
        // Assuming tokens are approved...

        bytes memory data = ""; // If additional data is not needed

        // Consider delaying this to get Pool created for sure

        (uint256 amount0, uint256 amount1) = IUniswapV3Pool(pool).mint(
            msg.sender, // or another recipient
            tickLower,
            tickUpper,
            liquidityAmount,
            data
        );

        // Additional logic to handle amount0 and amount1 if necessary
    }

    /** @notice Adds possibility to receive funds by this contract, which is required by MFM contract */
    receive() external payable {
        emit FundsReceived(msg.value);
    }

    /** @notice ??? */
    function getUserTokenBalance(address user, address token) external view returns (uint) {
        return IERC20(token).balanceOf(user);
    }
}
