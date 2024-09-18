// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IGweiPump} from "./interfaces/IGweiPump.sol";
import {IERC20} from "./interfaces/IERC20.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "chainlink/v0.8/interfaces/AggregatorV3Interface.sol"; 
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 
// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import {KeeperCompatibleInterface} from "chainlink/v0.8/KeeperCompatible.sol"; 
import {Owned} from "solmate/auth/Owned.sol";

contract GweiPump is ChainlinkClient, KeeperCompatibleInterface , Owned , IGweiPump {

    uint256 public isPumpFilled = 1;
    uint256 public lastWtiPriceCheckUnixTime;
    uint256 public wtiPriceOracle; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    address public constant chainlinkTokenAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    AggregatorV3Interface internal priceFeedETHforUSD;
    using Chainlink for Chainlink.Request;

    constructor() Owned(msg.sender) {
        priceFeedETHforUSD =  AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada); //Pricefeed addresses: https://docs.chain.link/docs/data-feeds/price-feeds/addresses/?network=polygon#Mumbai%20Testnet
        _setChainlinkToken(chainlinkTokenAddress); //Needed for Chainlink node data requests.
    }

    function chainlinkNodeRequestWtiPrice() public returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest("bbf0badad29d49dc887504bacfbb905b", address(this), this.fulfill.selector); //UINT
        request._add("get", "https://datasource.kapsarc.org/api/records/1.0/search/?dataset=spot-prices-for-crude-oil-and-petroleum-products&q=&facet=period");
        request._add("path", "records.0.fields.cushing_ok_wti_spot_price_fob_daily");
        int timesAmount = 100000000;
        request._addInt("times", timesAmount);
        return _sendChainlinkRequestTo(0xc8D925525CA8759812d0c299B90247917d4d4b7C, request, 10**16); //0.01 LINK
    }

    function fulfill(bytes32 _requestId, uint memoryWtiPriceOracle) public recordChainlinkFulfillment(_requestId) {
        if(memoryWtiPriceOracle > 0) {
            wtiPriceOracle = memoryWtiPriceOracle;
        }
        lastWtiPriceCheckUnixTime = block.timestamp;
        emit updateWti();
    }

    function getLatestMaticUsd() public view returns (int) { // Use MATIC since 40 Milliliters is not expensive and we can pay MATIC, easy to see in Metamask.
        (
            // uint80 roundID, 
            // int price, 
            // uint startedAt, 
            // uint timeStamp, 
            // uint80 answeredInRound
             ,int256 price, , ,
        ) = priceFeedETHforUSD.latestRoundData();
        return price;
    }

    function getLatestWtiMatic() public view returns (uint256) { // Have a 0.3% fee with (1003*price)/1000
        return uint256( ((int256(wtiPriceOracle*1003)*(10**18))/(1000)) / getLatestMaticUsd() );
    }

    function Wti40Milliliters() public view returns (uint256) { // 1 US BBL = 158987.29 mL => WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )
        return ( (4000*getLatestWtiMatic() ) /15898729);
    }

    function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = ( 
            ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) 
            && 
            (IERC20(address(chainlinkTokenAddress)).balanceOf(address(this)) >= (0.01 ether) ) 
        );
    }

    function performUpkeep(bytes calldata) external override {
        chainlinkNodeRequestWtiPrice();
    }

    function manualUpKeep() public {
        if(false == ( 
            ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) 
            && 
            (IERC20(address(chainlinkTokenAddress)).balanceOf(address(this)) >= (0.01 ether) ) )) 
            {revert upKeepNotNeeded(); }
        chainlinkNodeRequestWtiPrice();
    }

    function buyOil40Milliliters() public payable  {
        if(isPumpFilled == 0) { revert pumpNotFilled(); }
        if(Wti40Milliliters() == 0) { revert oraclePriceFeedZero(); }
        if(msg.value < Wti40Milliliters() ) { revert msgValueTooSmall(); } // Price for MSG.VALUE can change in mempool. Allow user to overpay then refund them.
        isPumpFilled = 0;
        if(msg.value > Wti40Milliliters() ) { //Refund user if they overpaid.
            (bool sentUser, ) = payable(msg.sender).call{value: msg.value -  Wti40Milliliters()}("");
            if(sentUser == false) revert etherNotSent(); 
        }
        (bool sentOwner, ) = payable(owner).call{value: address(this).balance}("");
        if(sentOwner == false) revert etherNotSent();     
        emit oilBought();
    }

    function ownerPumpFilledStatus(uint256 status) public onlyOwner {
        isPumpFilled = status;
    }

}
