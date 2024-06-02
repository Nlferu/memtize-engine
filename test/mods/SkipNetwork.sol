// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SkipNetwork {
    /// @dev Events
    event ForkNetworkSkipped();
    event LocalNetworkSkipped();

    /// @dev Modifiers
    modifier skipForkNetwork() {
        /// @dev Comment below 'if' statement line to perform full coverage test with commands from Makefile for example 'make testForkMainnetCoverage'
        if (block.chainid != 31337) return;
        emit ForkNetworkSkipped();

        _;
    }

    modifier skipLocalNetwork() {
        if (block.chainid == 31337) return;

        emit LocalNetworkSkipped();

        _;
    }
}
