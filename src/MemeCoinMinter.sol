// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CoinTemplate} from "./CoinTemplate.sol";

interface IERC20 {
    /** @notice Allows to transfer tokens from any address to any recipient */
    function transferFrom(address from, address to, uint amount) external returns (bool);

    /** @notice Allows to transfer tokens from this address to recipient */
    function transfer(address to, uint amount) external returns (bool);

    /** @notice Allows to check token balance for certain address */
    function balanceOf(address account) external view returns (uint);
}

contract MemeCoinMinter {
    event TokenCreated(address tokenAddress, string tokenName, string tokenSymbol);

    address[] public tokens;

    function mintToken(
        string memory name,
        string memory symbol,
        address creator,
        address team,
        address[] memory recipients,
        uint[] memory amounts,
        uint totalFunds
    ) external payable {
        CoinTemplate newToken = new CoinTemplate(name, symbol, creator, team, recipients, amounts, totalFunds);

        // This should be removed, changed or moved to other contract
        tokens.push(address(newToken));

        emit TokenCreated(address(newToken), name, symbol);
    }

    function getUserTokenBalance(address user, address token) external view returns (uint) {
        return IERC20(token).balanceOf(user);
    }
}
