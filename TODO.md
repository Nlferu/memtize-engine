1. Implement Calling Uniswap Dex to create liquidity Pool
2. Implement Chainlink Automation

DYM -> 0x4402ae3aC2e643201AbA1FA3555Fb7369936b92F
Pool -> 0xDe1c99195586AbCCE40Ee846D7fDC040DE288ce6

Add Liquidity = pool.mint

recipient: The address that will receive the liquidity provider (LP) tokens.
tickLower: The lower bound of the tick range where liquidity is to be added.
tickUpper: The upper bound of the tick range.
amount: The amount of liquidity to add.
data: Any additional data that may be needed. This is typically used for callback purposes.
