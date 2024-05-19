// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MemeCoin} from "../../src/MemeCoin.sol";
import {IMemeCoinMinter} from "../../src/Interfaces/IMemeCoinMinter.sol";

contract MemeCoinMinterTest is Test {
    function test_CantDeployMemeCoin() public skipFork {
        address[] memory recipients = new address[](3);
        recipients[0] = address(this);
        recipients[1] = address(this);
        recipients[2] = address(this);

        uint[] memory amounts = new uint[](2);
        amounts[0] = 33;
        amounts[1] = 666;

        IMemeCoinMinter.MintParams memory params = IMemeCoinMinter.MintParams({
            name: "Test",
            symbol: "TST",
            creator: address(this),
            team: address(this),
            recipients: recipients,
            amounts: amounts,
            totalMemeCoins: 1_476_000_000,
            totalFunds: 1476,
            mcd: address(this)
        });

        vm.expectRevert(MemeCoin.MC__ArraysNotParallel.selector);
        new MemeCoin(params);
    }

    function test_MemeCoinConstructor() public skipFork {
        address[] memory recipients = new address[](3);
        recipients[0] = address(this);
        recipients[1] = address(this);
        recipients[2] = address(this);

        uint[] memory amounts = new uint[](3);
        amounts[0] = 33;
        amounts[1] = 666;
        amounts[2] = 777;

        IMemeCoinMinter.MintParams memory params = IMemeCoinMinter.MintParams({
            name: "Test",
            symbol: "TST",
            creator: address(this),
            team: address(this),
            recipients: recipients,
            amounts: amounts,
            totalMemeCoins: 1_476_000_000,
            totalFunds: 1476,
            mcd: address(this)
        });

        MemeCoin memeCoinMinter = new MemeCoin(params);

        assertEq(memeCoinMinter.name(), "Test");
        assertEq(memeCoinMinter.symbol(), "TST");
    }

    modifier skipFork() {
        /// @dev Comment below 'if' statement line to perform full coverage test with command 'make testForkSepoliaCoverage'
        // if (block.chainid != 31337) return;

        _;
    }
}
