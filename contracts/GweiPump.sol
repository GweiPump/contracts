// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

error notOwner(); //Using custom errors with revert saves gas compared to using require.
error pumpNotFilled();
error msgValueTooSmall();
error oraclePriceFeedZero();

contract GweiPump is ChainlinkClient, KeeperCompatibleInterface {

    uint public isPumpFilled = 1;
    uint public lastWtiPriceCheckUnixTime;
    uint public WtiPriceOracle; //Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    address public immutable Owner;// Slot 2: 32/32 Owner never changes, use immutable to save gas.
    int public immutable feeThreeThousandthPercent = 3;
    // int public immutable mockPriceWTI = 8476500000; //Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    AggregatorV3Interface internal priceFeedETHforUSD;
    using Chainlink for Chainlink.Request;

    constructor() {
        Owner = msg.sender;
        priceFeedETHforUSD =  AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada); //Pricefeed addresses: https://docs.chain.link/docs/data-feeds/price-feeds/addresses/?network=polygon#Mumbai%20Testnet
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //Needed for Chainlink requests.
    }

    function chainlinkNodeRequestWtiPrice() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest("bbf0badad29d49dc887504bacfbb905b", address(this), this.fulfill.selector); //UINT
        request.add("get", "https://datasource.kapsarc.org/api/records/1.0/search/?dataset=spot-prices-for-crude-oil-and-petroleum-products&q=&facet=period");
        request.add("path", "records.0.fields.europe_brent_spot_price_fob_daily");
        int timesAmount = 100000000;
        request.addInt("times", timesAmount);
        return sendChainlinkRequestTo(0xc8D925525CA8759812d0c299B90247917d4d4b7C, request, 10**16); //0.01 LINK
    }

    function fulfill(bytes32 _requestId, uint256 memoryWtiPriceOracle) public recordChainlinkFulfillment(_requestId) {
        if(memoryWtiPriceOracle > 0) {
            WtiPriceOracle = memoryWtiPriceOracle;
        }
        lastWtiPriceCheckUnixTime = block.timestamp;
    }

    function getLatestMaticUsd() public view returns (int) { // Use MATIC since 40 Milliliters is not expensive and we can pay MATIC, easy to see in Metamask.
        (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedETHforUSD.latestRoundData();
        return price;
    }

    // function getLatesWtiUsd() public view returns (uint) {
    //     return uint( (mockPriceWTI*(10**18)*((1000+feeThreeThousandthPercent)/1000)) / getLatestEthUsd() );
    // }

    function getLatestWtiUsd() public view returns (uint) {
        return uint( (int(WtiPriceOracle)*(10**18)*((1000+feeThreeThousandthPercent)/1000)) / getLatestMaticUsd() );
    }

    function Wti40Milliliters() public view returns (uint) { // 1 US BBL = 158987.29 mL => WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )
        return ( (4000*getLatestWtiUsd() ) /15898729);
    }

    function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
        //CHECK IF LINK BALANCE IS GREATER THAN 0.01 LINK
        upkeepNeeded = ( (block.timestamp+120) > lastWtiPriceCheckUnixTime );
    }

    function performUpkeep(bytes calldata) external override {
        chainlinkNodeRequestWtiPrice();
    }

    function buyOneBarrelOil() public payable  {
        if(isPumpFilled == 0) { revert pumpNotFilled(); }
        if(Wti40Milliliters() == 0) { revert oraclePriceFeedZero(); }
        if(msg.value < Wti40Milliliters() ) { revert msgValueTooSmall(); } // Price for MSG.VALUE can change in mempool. Allow user to overpay then refund them.
        isPumpFilled = 0;
        if(msg.value > Wti40Milliliters() ) { //Refund user if they overpaid.
            payable(msg.sender).transfer(msg.value -  Wti40Milliliters() );
        }
        payable(Owner).transfer(address(this).balance);
    }

    function ownerPumpFilledStatus(uint status) public {
        if(msg.sender != Owner){ revert notOwner();}
        isPumpFilled = status;
    }

}
