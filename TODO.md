1. Implement Calling Uniswap Dex to create liquidity Pool
2. Implement Chainlink Automation

DYM -> 0x4402ae3aC2e643201AbA1FA3555Fb7369936b92F
Pool -> 0xDe1c99195586AbCCE40Ee846D7fDC040DE288ce6
WETH -> 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
Uniswap Factory -> https://sepolia.etherscan.io/address/0x0227628f3F023bb0B980b67D528571c95c6DaC1c

Add Liquidity = pool.mint

recipient: The address that will receive the liquidity provider (LP) tokens.
tickLower: The lower bound of the tick range where liquidity is to be added.
tickUpper: The upper bound of the tick range.
amount: The amount of liquidity to add.
data: Any additional data that may be needed. This is typically used for callback purposes.

Uniswap GitHub: https://github.com/Uniswap/v3-core/blob/v1.0.0/contracts/UniswapV3Pool.sol
