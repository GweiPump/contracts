# Contracts

## :oil_drum: GweiPump

### Chainlink Pricefeeds

  -MATIC/USD converted to on WTI/USD

  -Using MATIC/USD pricefeed from Chainlink contract:

  https://mumbai.polygonscan.com/address/0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada#code

### Chainlink Node GET Request uint 

  -WTI/USD is on Ethereum Mainnet but not Mumbai, so GET WTI/USD from Kapsarc using LinkRiver Chainlink node request:

  https://datasource.kapsarc.org/explore/dataset/spot-prices-for-crude-oil-and-petroleum-products/api/

  Kapsarc open source JSON WTI/USD URL (latest WTI/USD JSON path:

  https://datasource.kapsarc.org/api/records/1.0/search/?dataset=spot-prices-for-crude-oil-and-petroleum-products&q=&facet=period

  with JSON path for WTI/USD:

        records.0.fields.cushing_ok_wti_spot_price_fob_daily

  -Allow user to overpay for oil, then refund them if price changes while their payment is stuck in the mempool

  -Converting 1 barrel price 40 milliliters [1 US bbl oil= 158987.29mL]:
  https://www.metric-conversions.org/volume/us-oil-barrels-to-milliliters.htm
  1 US BBL = 158987.29 mL =>
  WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )

  -Using LinkRiver node to get WTI/USD on Mumbai:

  nodes: https://linkriver.io/#nodes

  jobId: https://market.link/nodes/63a49b1a-1951-4887-8f3f-8684d70c41ea/jobs?network=80001

### Chainlink Keepers

  -Chainlink Keepers updates WTI/USD based timer on 1 day timer
  and if contract has >= 0.01 LINK [LinkRiver node request fee] )

  Chainlink Keepers Log:

  https://automation.chain.link/mumbai/6989339503514991400051131250819682806817201475595233657790971703276505316631

Hardhat Solidity Coverage 100%:

<img src="https://github.com/GweiPump/contracts/blob/main/tests/unit/testOutput.png" alt="Test"/>


## :cocktail: Vocktails

### Chainlink VRFv2

  Get random drinks from robotics pump with Chainlink VRFv2.

  Vocktails VRFv2 Subscription:

  https://vrf.chain.link/mumbai/2217

## :camera: Slide Presentation

https://docs.google.com/presentation/d/1En3P14oi3CUcIWOaYxlzi5li4qDtajm3q3V0JpJfAYk/edit?usp=sharing

## :red_circle: Chainlink Universal Adapter Request: Node.js Puppeteer XPATH Web Scrape (offline) :red_circle:

  WTI/USD on Chainlink website: https://data.chain.link/ethereum/mainnet/commodities/wti-usd

  Chainlink website XPATH:
  /html/body/div[1]/main/section[2]/div[1]/div[1]/div[2]/p

  :warning:

  Puppeteer having trouble reading from XPATH [use the above working link instead]:

  Value on Etherscan on this page:
  https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract

  Etherscan XPATH:
  /html/body/div[4]/div[8]/div[2]/div/form/div

  :warning:
