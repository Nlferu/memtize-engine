// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DexYourMeme {
    event FundsReceived(uint indexed amount);

    fallback() external payable {
        emit FundsReceived(msg.value);
    }
}
