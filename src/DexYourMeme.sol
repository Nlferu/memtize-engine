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
    event FundsReceived(uint indexed amount);
    event FundsReceivedFall(uint indexed amount); // -> this to be removed

    receive() external payable {
        emit FundsReceived(msg.value);
    }

    fallback() external payable {
        emit FundsReceivedFall(msg.value);
    }

    function getUserTokenBalance(address user, address token) external view returns (uint) {
        return IERC20(token).balanceOf(user);
    }
}
