// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/// @notice Example ERC20 token for testing
contract Asta is ERC20 {
    //uint256 private constant;

    constructor(uint256 initialSupply) ERC20("Asta", "AST", 18) {
        _mint(msg.sender, initialSupply);
    }
}
