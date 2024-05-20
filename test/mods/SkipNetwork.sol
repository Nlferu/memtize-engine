// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SkipNetwork {
    event ForkNetworkSkipped();
    event LocalNetworkSkipped();

    modifier skipForkNetwork() {
        /// @dev Comment below 'if' statement line to perform full coverage test with command 'make testForkSepoliaCoverage'
        // if (block.chainid != 31337) return;
        emit ForkNetworkSkipped();

        _;
    }

    modifier skipLocalNetwork() {
        if (block.chainid == 31337) return;

        emit LocalNetworkSkipped();

        _;
    }
}
