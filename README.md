# Memtize Engine

**Memtize consists of:**

-   **Meme Coin**: Template for crafting new meme coins.
-   **Meme Coin Minter**: Coins factory contract for minting meme coins among all participants (creator, memtize, funders, liquidity pool).
-   **Meme Coin Dexer**: Creating liquidity pool on Uniswap v3 and adding liquidity to it for newly crafted coins, so rest of community can trade that coin.
-   **Meme Process Manager**: Allows creating and funding memes. It automatically hype (listing on Uniswap v3) or kill (delete) based on time passed and funds gathered for each meme.

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
