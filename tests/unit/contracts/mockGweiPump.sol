// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error notOwner(); //Using custom errors with revert saves gas compared to using require.
error pumpNotFilled();
error msgValueTooSmall();
error oraclePriceFeedZero();
error upKeepNotNeeded();

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LINK is ERC20{

    address immutable Owner;

    constructor() ERC20("Wrapped Ether","LINK") {
        Owner = msg.sender;
        _mint(Owner,(1000)*(1 ether) );
    }

}

contract ERC20TokenContract is ERC20("ChainLink Token", "LINK") {}

// contract mockGweiPump is ChainlinkClient, KeeperCompatibleInterface {
contract mockGweiPump {


    uint public isPumpFilled = 1;
    uint public lastWtiPriceCheckUnixTime;
    uint public WtiPriceOracle; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    address public immutable Owner;// Slot 2: 32/32 Owner never changes, use immutable to save gas.
    int public immutable feeThreeThousandthPercent = 3;

    event oilBought();
    event updateWti();

    // AggregatorV3Interface internal priceFeedETHforUSD;
    ERC20TokenContract public erc20LINK;
    // using Chainlink for Chainlink.Request;

    constructor(address mockLinkAddress) {
        Owner = msg.sender;
        // priceFeedETHforUSD =  AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada); //Pricefeed addresses: https://docs.chain.link/docs/data-feeds/price-feeds/addresses/?network=polygon#Mumbai%20Testnet
        // erc20LINK = ERC20TokenContract(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //ChainlinkToken on Mumbai;
        erc20LINK = ERC20TokenContract(mockLinkAddress); //ChainlinkToken on Mumbai;
        // setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //Needed for Chainlink node data requests.
    }

    // function chainlinkNodeRequestWtiPrice() public returns (bytes32 requestId) {
    //     Chainlink.Request memory request = buildChainlinkRequest("bbf0badad29d49dc887504bacfbb905b", address(this), this.fulfill.selector); //UINT
    //     request.add("get", "https://datasource.kapsarc.org/api/records/1.0/search/?dataset=spot-prices-for-crude-oil-and-petroleum-products&q=&facet=period");
    //     request.add("path", "records.0.fields.europe_brent_spot_price_fob_daily");
    //     int timesAmount = 100000000;
    //     request.addInt("times", timesAmount);
    //     return sendChainlinkRequestTo(0xc8D925525CA8759812d0c299B90247917d4d4b7C, request, 10**16); //0.01 LINK
    // }

    function mockChainlinkNodeRequestWtiPrice(uint mockOracleValue) public {
        // Chainlink.Request memory request = buildChainlinkRequest("bbf0badad29d49dc887504bacfbb905b", address(this), this.fulfill.selector); //UINT
        // request.add("get", "https://datasource.kapsarc.org/api/records/1.0/search/?dataset=spot-prices-for-crude-oil-and-petroleum-products&q=&facet=period");
        // request.add("path", "records.0.fields.europe_brent_spot_price_fob_daily");
        // int timesAmount = 100000000;
        // request.addInt("times", timesAmount);
        // return sendChainlinkRequestTo(0xc8D925525CA8759812d0c299B90247917d4d4b7C, request, 10**16); //0.01 LINK
        mockfulfill(mockOracleValue);
    }

    // function fulfill(bytes32 _requestId, uint256 memoryWtiPriceOracle) public recordChainlinkFulfillment(_requestId) {
    //     if(memoryWtiPriceOracle > 0) {
    //         WtiPriceOracle = memoryWtiPriceOracle;
    //     }
    //     lastWtiPriceCheckUnixTime = block.timestamp;
    //     emit updateWti();
    // }

    function mockfulfill(uint memoryWtiPriceOracle) public {
        if(memoryWtiPriceOracle > 0) {
            WtiPriceOracle = memoryWtiPriceOracle;
        }
        lastWtiPriceCheckUnixTime = block.timestamp;
        emit updateWti();
    }

    // function getLatestMaticUsd() public view returns (int) { // Use MATIC since 40 Milliliters is not expensive and we can pay MATIC, easy to see in Metamask.
    //     (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedETHforUSD.latestRoundData();
    //     return price;
    // }

    function mockGetLatestMaticUsd() public view returns (int) { // Use MATIC since 40 Milliliters is not expensive and we can pay MATIC, easy to see in Metamask.
        // (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedETHforUSD.latestRoundData();
        return 80087692;
    }

    // function getLatestWtiMatic() public view returns (uint) {
    //     return uint( (int(WtiPriceOracle)*(10**18)*((1000+feeThreeThousandthPercent)/1000)) / getLatestMaticUsd() );
    // }

    function mockGetLatestWtiMatic() public view returns (uint) {
        return uint( (int(WtiPriceOracle)*(10**18)*((1000+feeThreeThousandthPercent)/1000)) / mockGetLatestMaticUsd() );
    }

    // function Wti40Milliliters() public view returns (uint) { // 1 US BBL = 158987.29 mL => WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )
    //     return ( (4000*getLatestWtiUsd() ) /15898729);
    // }

    function mockWti40Milliliters() public view returns (uint) { // 1 US BBL = 158987.29 mL => WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )
        return ( (4000*mockGetLatestWtiMatic() ) /15898729);
    }

    // function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
    //     upkeepNeeded = ( ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) && (erc20LINK.balanceOf(address(this)) >= (0.01 ether) ) );
    // }

    // function performUpkeep(bytes calldata) external override {
    //     chainlinkNodeRequestWtiPrice();
    // }

    // function manualUpKeep() public {
    //     if(false == ( ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) && (erc20LINK.balanceOf(address(this)) >= (0.01 ether) ) )) {revert upKeepNotNeeded(); }
    //     chainlinkNodeRequestWtiPrice();
    // }

    function manualUpKeep(uint mockOracleValue) public {
        if(false == ( ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) && (erc20LINK.balanceOf(address(this)) >= (0.01 ether) ) )) {revert upKeepNotNeeded(); }
        mockChainlinkNodeRequestWtiPrice(mockOracleValue);
    }

    // function buyOil40Milliliters() public payable  {
    //     if(isPumpFilled == 0) { revert pumpNotFilled(); }
    //     if(Wti40Milliliters() == 0) { revert oraclePriceFeedZero(); }
    //     if(msg.value < Wti40Milliliters() ) { revert msgValueTooSmall(); } // Price for MSG.VALUE can change in mempool. Allow user to overpay then refund them.
    //     isPumpFilled = 0;
    //     if(msg.value > Wti40Milliliters() ) { //Refund user if they overpaid.
    //         payable(msg.sender).transfer(msg.value -  Wti40Milliliters() );
    //     }
    //     payable(Owner).transfer(address(this).balance);
    //     emit oilBought();
    // }

    function mockBuyOil40Milliliters() public payable  {
        if(isPumpFilled == 0) { revert pumpNotFilled(); }
        if(mockWti40Milliliters() == 0) { revert oraclePriceFeedZero(); }
        if(msg.value < mockWti40Milliliters() ) { revert msgValueTooSmall(); } // Price for MSG.VALUE can change in mempool. Allow user to overpay then refund them.
        isPumpFilled = 0;
        if(msg.value > mockWti40Milliliters() ) { //Refund user if they overpaid.
            payable(msg.sender).transfer(msg.value -  mockWti40Milliliters() );
        }
        payable(Owner).transfer(address(this).balance);
        emit oilBought();
    }

    function ownerPumpFilledStatus(uint status) public {
        if(msg.sender != Owner){ revert notOwner();}
        isPumpFilled = status;
    }

}
