# Contracts

## GweiPump

  -MATIC/USD converted to on WTI/USD

  -Allow user to overpay for oil, then refund them if price changes while their payment is stuck in the mempool

  -Converting 1 barrel price 40 milliliters [1 US bbl oil= 158987.29mL]:
  https://www.metric-conversions.org/volume/us-oil-barrels-to-milliliters.htm
  1 US BBL = 158987.29 mL =>
  WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )

  -Using LinkRiver node to get WTI/USD on Mumbai:
  nodes: https://linkriver.io/#nodes
  jobId: https://market.link/nodes/63a49b1a-1951-4887-8f3f-8684d70c41ea/jobs?network=80001

  -Chainlink Keepers updates WTI/USD based timer on daily timer,
  and if contract has >= 0.01 LINK [LinkRiver node request fee] )
  https://automation.chain.link/mumbai/36355086272015919814976068457284744937532473452883708021113428603360821554132

  *Get WTI/USD priceFeed from Ethereum Mainnet using Universal Adapter Chainlink Oracle daily if the contract has 1
  LINK [just change the current logic check to 1 LINK instead of 0.01 LINK].

  WTI/USD on Chainlink website: https://data.chain.link/ethereum/mainnet/commodities/wti-usd

  Chainlink website XPATH:
  /html/body/div[1]/main/section[2]/div[1]/div[1]/div[2]/p

  Value on Etherscan on this page:
  https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract

  Etherscan XPATH:
  /html/body/div[4]/div[8]/div[2]/div/form/div


## Vocktails

  Get random drinks from robotics pump with Chainlink VRFv2.

  Vocktails VRFv2 Subscription:

  https://vrf.chain.link/mumbai/2217
