// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CoinTemplate} from "./CoinTemplate.sol";

contract MemeCoinMinter {
    event TokenCreated(address tokenAddress, string tokenName, string tokenSymbol);

    function mintToken(string memory name, string memory symbol, address[] memory recipients, uint256[] memory amounts) external {
        CoinTemplate newToken = new CoinTemplate(name, symbol, recipients, amounts);

        emit TokenCreated(address(newToken), name, symbol);
    }
}
