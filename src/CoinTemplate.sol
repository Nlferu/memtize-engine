// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CoinTemplate is ERC20 {
    constructor(string memory name, string memory symbol, address[] memory recipients, uint256[] memory amounts) ERC20(name, symbol) {
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
        }
    }
}
