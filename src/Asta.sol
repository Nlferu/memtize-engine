// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Example ERC20 token for testing
contract Asta is ERC20 {
    /// @dev Minting 1kkk tokens
    uint256 private constant supply = 1_000_000_000 * 10 ** 18;

    constructor() ERC20("Asta", "AST") {
        _mint(msg.sender, supply);
    }
}
