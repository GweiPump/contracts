# Contracts

## GweiPump

  Chainlink ETH/USD priceFeed used instead of MATIC/USD since MATIC faucet is limited on Mumbai

  *Will use Chainlink Keepers to update the WTI/USD priceFeed
  from Ethereum Mainnet using Universal Adapter Chainlink Oracle daily if the contract has 1 LINK.

  *If the oracle returns 0, then do not update the state.

  *Will convert 1 barrel to milliliters needed [1 US bbl oil= 158987.29mL]
  https://www.metric-conversions.org/volume/us-oil-barrels-to-milliliters.htm

## Vocktails

  Get random drinks from robotics pump with Chainlink VRFv2.
