// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address nftPositionManager;
        address wrappedNativeToken;
        address swapRouter;
        uint256 deployerKey;
    }

    constructor() {
        if (block.chainid == 1) activeNetworkConfig = getMainnetConfig();
        if (block.chainid == 137) activeNetworkConfig = getPolygonConfig();
        if (block.chainid == 43114) activeNetworkConfig = getAvalancheConfig();
        if (block.chainid == xx) activeNetworkConfig = getMoonbeamConfig();
        if (block.chainid == 534351) activeNetworkConfig = getScrollSepoliaConfig();
        if (block.chainid == 11155111) activeNetworkConfig = getSepoliaConfig();
        if (block.chainid == 31337) activeNetworkConfig = getLocalConfig();
    }

    function getMainnetConfig() public view returns (NetworkConfig memory mainnetNetworkConfig) {
        mainnetNetworkConfig = NetworkConfig({
            nftPositionManager: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88,
            wrappedNativeToken: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            swapRouter: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getPolygonConfig() public view returns (NetworkConfig memory polygonNetworkConfig) {
        polygonNetworkConfig = NetworkConfig({
            nftPositionManager: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88,
            wrappedNativeToken: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270,
            swapRouter: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getAvalancheConfig() public view returns (NetworkConfig memory avalancheNetworkConfig) {
        avalancheNetworkConfig = NetworkConfig({
            nftPositionManager: 0x655C406EBFa14EE2006250925e54ec43AD184f8B,
            wrappedNativeToken: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7,
            swapRouter: 0xbb00FF08d01D300023C629E8fFfFcb65A5a578cE,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getScrollSepoliaConfig() public view returns (NetworkConfig memory scrollSepoliaNetworkConfig) {
        scrollSepoliaNetworkConfig = NetworkConfig({
            nftPositionManager: 0x1238536071E1c677A632429e3655c799b22cDA52,
            wrappedNativeToken: 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14,
            swapRouter: 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            nftPositionManager: 0x1238536071E1c677A632429e3655c799b22cDA52,
            wrappedNativeToken: 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14,
            swapRouter: 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getLocalConfig() public view returns (NetworkConfig memory localNetworkConfig) {
        localNetworkConfig = NetworkConfig({
            nftPositionManager: address(0),
            wrappedNativeToken: address(0),
            swapRouter: address(0),
            deployerKey: vm.envUint("LOCAL_PRIVATE_KEY")
        });
    }
}
