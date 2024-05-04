// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CoinTemplate} from "./CoinTemplate.sol";

contract MemeCoinMinter {
    event TokenCreated(address indexed tokenAddress, string tokenName, string tokenSymbol);

    address[] private tokens;

    function mintToken(
        string memory name,
        string memory symbol,
        address creator,
        address team,
        address[] memory recipients,
        uint[] memory amounts,
        uint totalFunds,
        address dym
    ) external {
        CoinTemplate newToken = new CoinTemplate(name, symbol, creator, team, recipients, amounts, totalFunds, dym);

        // This should be removed, changed or moved to other contract
        tokens.push(address(newToken));

        emit TokenCreated(address(newToken), name, symbol);
    }

    function getTokensMinted() external view returns (address[] memory) {
        return tokens;
    }
}
