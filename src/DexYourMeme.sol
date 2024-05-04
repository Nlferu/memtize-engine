// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    /** @notice Allows to transfer tokens from any address to any recipient */
    function transferFrom(address from, address to, uint amount) external returns (bool);

    /** @notice Allows to transfer tokens from this address to recipient */
    function transfer(address to, uint amount) external returns (bool);

    /** @notice Allows to check token balance for certain address */
    function balanceOf(address account) external view returns (uint);
}

contract DexYourMeme {
    error DYM__DexMemeFailed();

    event FundsReceived(uint indexed amount);
    event MemeDexedSuccessfully(address indexed token);

    address private constant UNISWAP_FACTORY = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

    function dexMeme() external {
        (bool success, ) = UNISWAP_FACTORY.call(abi.encodeWithSignature(""));

        if (!success) revert DYM__DexMemeFailed();

        emit MemeDexedSuccessfully();
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
