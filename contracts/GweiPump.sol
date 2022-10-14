// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error notOwner(); //Using custom errors with revert saves gas compared to using require.
error pumpNotFilled();
error msgValueTooSmall();

contract GweiPump {

    uint public isPumpFilled = 1;
    address public immutable Owner;// Slot 2: 32/32 Owner never changes, use immutable to save gas.
    int public immutable feeThreeThousandthPercent = 3;
    int public immutable mockPriceWTI = 8476500000; //Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    AggregatorV3Interface internal priceFeedETHforUSD;

    constructor() {
        Owner = msg.sender;
        priceFeedETHforUSD =  AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A); //Pricefeed addresses: https://docs.chain.link/docs/data-feeds/price-feeds/addresses/?network=polygon#Mumbai%20Testnet
    }

    function getLatestEthUsd() public view returns (int) { // Let MATIC = ETH in price since MATIC faucet is limited on Mumbai.
        (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedETHforUSD.latestRoundData();
        return price;
    }

    function getLatesWtiUsd() public view returns (uint) {
        return uint( (mockPriceWTI*(10**18)*((1000+feeThreeThousandthPercent)/1000)) / getLatestEthUsd() );
    }

    function buyOneBarrelOil() public payable  {
        if(isPumpFilled == 0) { revert pumpNotFilled(); }
        if(msg.value < getLatesWtiUsd() ) { revert msgValueTooSmall(); } // Price for MSG.VALUE can change in mempool. Allow user to overpay then refund them.
        isPumpFilled = 0;
        if(msg.value > getLatesWtiUsd() ) { //Refund user if they overpaid.
            payable(msg.sender).transfer(msg.value -  getLatesWtiUsd() );
        }
        payable(Owner).transfer(address(this).balance);
    }

    function ownerPumpFilledStatus(uint status) public {
        if(msg.sender != Owner){ revert notOwner();}
        isPumpFilled = status;
    }

}
