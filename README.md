# Dex Your Meme

**Building something cool for Chainlink Block Magic Hackathon**

DYM consists of:

-   **x**: xxxxxxxxxxxxxx
-   **x**: xxxxxxxxxxxxxx
-   **x**: xxxxxxxxxxxxxx
-   **x**: xxxxxxxxxxxxxx

## Documentation

https://book.getfoundry.sh/

## Usage

Deploy Order:

1. MCM
2. MCD
3. MPM
4. Transfer ownership of MCM to MPM

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

#### Full Coverage

To get full coverage go to `test/mods/SkipNetwork.t.sol` find `skipForkNetwork()` modifier and comment it's if statement, then run below:

```bash
$ make testForkSepoliaCoverage
```

![Test Coverage](images/tests_coverage.png)

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```
