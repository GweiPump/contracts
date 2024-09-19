// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IGweiPump} from "./interfaces/IGweiPump.sol";
import {IERC20} from "./interfaces/IERC20.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "chainlink/v0.8/interfaces/AggregatorV3Interface.sol"; 
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";


// import {FunctionsClient} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsClient} from "chainlink/v0.8/functions/v1_0_0/FunctionsClient.sol"; 


// import {ConfirmedOwner} from "@chainlink/contracts@1.2.0/src/v0.8/shared/access/ConfirmedOwner.sol";
import {ConfirmedOwner} from "chainlink/v0.8/shared/access/ConfirmedOwner.sol"; 


// import {FunctionsRequest} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {FunctionsRequest} from "chainlink/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol"; 


// import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 

// import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 
// import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 
// import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 
// import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 

// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import {KeeperCompatibleInterface} from "chainlink/v0.8/KeeperCompatible.sol"; 
import {Owned} from "solmate/auth/Owned.sol";

contract GweiPump is KeeperCompatibleInterface , Owned , IGweiPump {

    // @notice Fee range defined in MAX_BPS is 10000 for 2 decimals places like Uniswap. 
    // Example with houseEdgeFeePercent = 30: 30/10000 = 3/1000 = 0.3%.
    // @dev Uniswap treats bps and ticks as the concept.
    // https://support.uniswap.org/hc/en-us/articles/21069524840589-What-is-a-tick-when-providing-liquidity
    int256 public constant MAX_BPS = 10000; 
    // @notice 0.3% fee like Uniswap.
    int256 public constant SCALE_FEE = 30; 

    uint256 public isPumpFilled = 1;
    uint256 public lastWtiPriceCheckUnixTime;
    uint256 public wtiPriceOracle; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    AggregatorV3Interface internal priceFeedETHforUSD;

    address public constant chainlinkTokenAddressSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    // Crude oil can go negative in theory (int). However, we will only accept prices greater than 0 (uint).
    string  private constant jobIdGetUint256Sepolia ="ca98366cc7314957b8c012c72f05aeeb"; 
    address private constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD; 

    constructor() Owned(msg.sender) {
        // Sepolia pricefeeds: 
        // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1&search=#sepolia-testnet
        priceFeedETHforUSD =  AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }  

    function getLatestEthUsd() public view returns (int256) { 
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
        return uint256( ( ( (int256(wtiPriceOracle)*(1 ether)*(MAX_BPS+SCALE_FEE)) )/(MAX_BPS)) / getLatestEthUsd() );
    }

    function getWti40Milliliters() public view returns (uint256) { // 1 US BBL = 158987.29 mL => WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )
        return ( (4000*getLatestWtiMatic() ) /15898729);
    }

    function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = ( 
            ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) 
            && 
            (IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this)) >= (0.01 ether) ) 
        );
    }

    function performUpkeep(bytes calldata) external override {
        // chainlinkNodeRequestWtiPrice();
    }

    function manualUpKeep() public {
        if(false == ( 
            ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) 
            && 
            (IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this)) >= (0.01 ether) ) )) 
            revert upKeepNotNeeded(); 
        // chainlinkNodeRequestWtiPrice();
    }

    function buyOil40Milliliters() public payable  {
        // Save the conversion in memory to save gas.
        uint256 currentWti40Milliliters = getWti40Milliliters();
        if(isPumpFilled == 0) revert pumpNotFilled();
        if(currentWti40Milliliters == 0) revert oraclePriceFeedZero();
        if(msg.value < currentWti40Milliliters ) revert msgValueTooSmall();  // Price for MSG.VALUE can change in mempool. Allow user to overpay then refund them.
        isPumpFilled = 0;
        if(msg.value > currentWti40Milliliters ) { //Refund user if they overpaid.
            (bool sentUser, ) = payable(msg.sender).call{value: msg.value - currentWti40Milliliters}("");
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
