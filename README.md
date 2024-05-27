# Memtize Engine

Website: https://www.

**Memtize consists of:**

-   **Meme Coin**: Template for crafting new meme coins.
-   **Meme Coin Minter**: Coins factory contract for minting meme coins among all participants (creator, memtize, funders, liquidity pool).
-   **Meme Coin Dexer**: Creating liquidity pool on Uniswap v3 and adding liquidity to it for newly crafted coins, so rest of community can trade that coin.
-   **Meme Process Manager**: Allows creating and funding memes. It automatically hype (listing on Uniswap v3) or kill (delete) based on time passed and funds gathered for each meme.

## Deployments

#### Sepolia Shortened Timers Project Version:

-   MemeCoinMinter: 0xd50Ba86d476D3d2CbFA3F5a92462ef95EAA437Ec
-   MemeCoinDexer: 0x5B4C3787A12e2Ee9Ad1890065e1111ea213eb37b
-   MemeProcessManager: 0x42D723B73867B000bEE295A7acEb5037E4f5e62e

#### Amoy Deployments:

-   MemeCoinMinter: 0x9b48eD75cd5b758c94339f1Db298458aE226814D
-   MemeCoinDexer: 0xE56c44b93e1210Dd6FD40c589d528b1572488732
-   MemeProcessManager: 0xAE253FE1226B576800ac11352F77131a7E6835Dd

#### Fuji Deployments:

-   MemeCoinMinter:
-   MemeCoinDexer:
-   MemeProcessManager:

#### Moonbeam Deployments:

-   MemeCoinMinter: 0x89C9040709ebce46e3b68E75c2664653E9816c9B
-   MemeCoinDexer: 0xaBC27F4fa9dae4829575A3DF7958b9d80872c8a8
-   MemeProcessManager: 0x4B8907E0e9Ad03650E6f734d4bbb2Ce65a3dC27D

#### Scroll Deployments:

-   MemeCoinMinter: 0x32edbbEDbE769725F1bB8Acf9fB43E070eE77cd3
-   MemeCoinDexer: 0x590Fb54FEB1A3aBd8D2D853756F2172a3210c359
-   MemeProcessManager: 0x4f848df81370275ABFBD91E798E4Cddc48A8BBac

## Documentation

https://book.getfoundry.sh/

## 💻 Usage

Demo App: https://www.

#### For local partial usage follow below:

-   Install `Foundry`
-   Create and fill `.env` file same as it is shown in `.env.example`
-   Run `anvil` command in terminal
-   Open new terminal window without closing one with `anvil`
-   Run `make deployMemtize` to deploy whole blockchain part of this project
-   Now you can play with it's basic functions from `MemeProcessManager` contract

#### Full usage:

You need to fork one of mainnets (Ethereum, Polygon, Avalanche) or just use testnet (Sepolia). As our protocol cooperates with Uniswap v3 it is fully usable only on mentioned networks as there are Uniswap contracts deployed officially by Uniswap Labs.

### 🧪 Test

```shell
$ forge test
```

### 🧪 Full Test Coverage

To get full coverage go to `test/mods/SkipNetwork.t.sol` find `skipForkNetwork()` modifier and comment it's if statement, then run below:

-   Mainnet

*   `make testForkMainnet`
*   `make testForkMainnetCoverage`

-   Sepolia Testnet

*   `make testForkSepolia`
*   `make testForkSepoliaCoverage`

-   Polygon

*   `make testForkPolygon`
*   `make testForkPolygonCoverage`

-   Avalanche

*   `make testForkAvalanche`
*   `make testForkAvalancheCoverage`

Our protocol has been tested fully on all above networks and has reached below results for each network:

![Test Coverage](images/tests_coverage.png)

### ⌨ Other Commands

You can find much more in `Makefile`

#### Build

```bash
$ forge build
```

#### Format

```bash
$ forge fmt
```

#### Gas Snapshots

This one is set to Mainnet, so first go to `test/mods/SkipNetwork.t.sol` find `skipForkNetwork()` modifier and comment it's if statement

```bash
$ make snapshot
```
