# Contracts

## :oil_drum: GweiPump

### Chainlink Pricefeeds

  -ETH/USD converted to on WTI/USD

### Chainlink Node GET Request uint

Yahoo Finance Cruide Oil Futures Price:

https://query1.finance.yahoo.com/v8/finance/chart/CL=F

  -Allow user to overpay for oil, then refund them if price changes while their payment is stuck in the mempool

  -Converting 1 barrel price 40 milliliters [1 US bbl oil= 158987.29mL]:
  https://www.metric-conversions.org/volume/us-oil-barrels-to-milliliters.htm
  1 US BBL = 158987.29 mL =>
  WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )

### Chainlink Keepers

  -Chainlink Keepers updates WTI/USD based timer on 1 day timer
  and if contract has >= 0.01 LINK [LinkRiver node request fee] )

  Chainlink Keepers Log Dashboard:

  https://automation.chain.link/

Hardhat Solidity Coverage 100%:

<img src="https://github.com/GweiPump/contracts/blob/main/tests/unit/testOutput.png" alt="Test"/>


## :cocktail: Vocktails

### Chainlink VRFv2

  Get random drinks from robotics pump with Chainlink VRFv2.

  Vocktails VRFv2 Dashboard:

  https://vrf.chain.link/

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

## Foundry 

:warning: Note: you might need to add libraries in forge with remappings.txt :warning:

## Install Chainlink libraries
```
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```
### Install Solmate Library
```
forge install rari-capital/solmate --no-commit
```