# Contracts

## GweiPump

  -MATIC/USD converted to on WTI/USD

  -Allow user to overpay for oil, then refund them if price changes while their payment is stuck in the mempool

  -Converting 1 barrel price 40 milliliters [1 US bbl oil= 158987.29mL]:
  https://www.metric-conversions.org/volume/us-oil-barrels-to-milliliters.htm
  1 US BBL = 158987.29 mL =>
  WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )

  *Will use Chainlink Keepers to update the WTI/USD priceFeed
  from Ethereum Mainnet using Universal Adapter Chainlink Oracle daily if the contract has 1 LINK.

  *If the oracle returns 0, then do not update the state.

## Vocktails

  Get random drinks from robotics pump with Chainlink VRFv2.
