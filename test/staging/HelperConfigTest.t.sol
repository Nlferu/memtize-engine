// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    HelperConfig helperConfig;

    address nftPositionManager;
    address wrappedNativeToken;
    address swapRouter;
    uint256 deployerKey;

    function test_MainnetConfig() public {
        vm.chainId(1);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getMainnetConfig();

        assertEq(config.nftPositionManager, 0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        assertEq(config.wrappedNativeToken, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assertEq(config.swapRouter, 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_SepoliaConfig() public {
        vm.chainId(11155111);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getSepoliaConfig();

        assertEq(config.nftPositionManager, 0x1238536071E1c677A632429e3655c799b22cDA52);
        assertEq(config.wrappedNativeToken, 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
        assertEq(config.swapRouter, 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_PolygonConfig() public {
        vm.chainId(137);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getPolygonConfig();

        assertEq(config.nftPositionManager, 0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        assertEq(config.wrappedNativeToken, 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        assertEq(config.swapRouter, 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_AmoyConfig() public {
        vm.chainId(80002);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getAmoyConfig();

        assertEq(config.nftPositionManager, 0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        assertEq(config.wrappedNativeToken, 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        assertEq(config.swapRouter, 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_AvalancheConfig() public {
        vm.chainId(43114);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getAvalancheConfig();

        assertEq(config.nftPositionManager, 0x655C406EBFa14EE2006250925e54ec43AD184f8B);
        assertEq(config.wrappedNativeToken, 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
        assertEq(config.swapRouter, 0xbb00FF08d01D300023C629E8fFfFcb65A5a578cE);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_FujiConfig() public {
        vm.chainId(43113);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getFujiConfig();

        assertEq(config.nftPositionManager, 0x655C406EBFa14EE2006250925e54ec43AD184f8B);
        assertEq(config.wrappedNativeToken, 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
        assertEq(config.swapRouter, 0xbb00FF08d01D300023C629E8fFfFcb65A5a578cE);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_MoonbeamConfig() public {
        vm.chainId(1287);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getMoonbeamConfig();

        assertEq(config.nftPositionManager, 0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        assertEq(config.wrappedNativeToken, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assertEq(config.swapRouter, 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_ScrollConfig() public {
        vm.chainId(534351);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getScrollConfig();

        assertEq(config.nftPositionManager, 0x1238536071E1c677A632429e3655c799b22cDA52);
        assertEq(config.wrappedNativeToken, 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
        assertEq(config.swapRouter, 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E);
        assertEq(config.deployerKey, vm.envUint("PRIVATE_KEY"));
    }

    function test_LocalConfig() public {
        vm.chainId(31337);
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getLocalConfig();

        assertEq(config.nftPositionManager, address(0));
        assertEq(config.wrappedNativeToken, address(0));
        assertEq(config.swapRouter, address(0));
        assertEq(config.deployerKey, vm.envUint("LOCAL_PRIVATE_KEY"));
    }
}
