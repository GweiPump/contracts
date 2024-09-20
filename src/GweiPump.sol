// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IGweiPump} from "./interfaces/IGweiPump.sol";
import {IERC20} from "./interfaces/IERC20.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "chainlink/v0.8/interfaces/AggregatorV3Interface.sol"; 
// import {FunctionsClient} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsClient} from "chainlink/v0.8/functions/v1_0_0/FunctionsClient.sol"; 
// import {FunctionsRequest} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {FunctionsRequest} from "chainlink/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol"; 
// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
// import {KeeperCompatibleInterface} from "chainlink/v0.8/KeeperCompatible.sol"; 
import {Owned} from "solmate/auth/Owned.sol";

// contract GweiPump is FunctionsClient , Owned , KeeperCompatibleInterface ,IGweiPump {
contract GweiPump is FunctionsClient , Owned , IGweiPump {

    // @notice Fee range defined in MAX_BPS is 10000 for 2 decimals places like Uniswap. 
    // Example with houseEdgeFeePercent = 30: 30/10000 = 3/1000 = 0.3%.
    // @dev Uniswap treats bps and ticks as the concept.
    // https://support.uniswap.org/hc/en-us/articles/21069524840589-What-is-a-tick-when-providing-liquidity
    int256 public constant MAX_BPS = 10000; 
    // @notice 0.3% fee like Uniswap.
    int256 public constant SCALE_FEE = 30; 

    uint256 public isPumpFilled = 1;
    uint256 public lastWtiPriceCheckUnixTime;

    AggregatorV3Interface internal priceFeedETHforUSD;

    address public constant chainlinkTokenAddressSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    // Crude oil can go negative in theory (int). However, we will only accept prices greater than 0 (uint).
    string  private constant jobIdGetUint256Sepolia ="ca98366cc7314957b8c012c72f05aeeb"; 
    address private constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD; 

    constructor() FunctionsClient(router)  Owned(msg.sender)  {
        // Sepolia pricefeeds: 
        // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1&search=#sepolia-testnet
        priceFeedETHforUSD =  AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function stringToBytes32(
        string memory inputString
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(inputString);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(inputString, 32))
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

    function getLatestWtiEth() public view returns (uint256) { // Have a 0.3% fee with (1003*price)/1000
        uint256 wtiPriceOracleUint = 7000;
        return uint256( ( ( (int256(wtiPriceOracleUint)*(1 ether)*(MAX_BPS+SCALE_FEE)) )/(MAX_BPS)) / getLatestEthUsd() );
    }

    function getWti40Milliliters() public view returns (uint256) { // 1 US BBL = 158987.29 mL => WtiConvert140mL() = (40.00 mL * getLatesWtiUsd() ) / 158987.29 mL = ( (4000*getLatesWtiUsd() ) / 15898729 )
        return ( (4000*getLatestWtiEth() ) /15898729);
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

    // Chainlink Functions logic

    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // // Custom error type
    // error UnexpectedRequestID(bytes32 requestId);

    // // Event to log responses
    // event Response(
    //     bytes32 indexed requestId,
    //     uint256 value,
    //     bytes response,
    //     bytes err
    // );

    // Router address - Hardcoded for Sepolia
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    address constant router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

    // JavaScript source code
    // Fetch character name from the Star Wars API.
    // Documentation: https://swapi.info/people
    string constant javascriptSourceCode = "const apiResponse = await Functions.makeHttpRequest({url: `https://query1.finance.yahoo.com/v8/finance/chart/CL=F`}); if (apiResponse.error) {console.error(apiResponse.error);throw Error('Request failed');} const { data } = apiResponse; console.log('API response data:'); const wtiUsdRaw = (data.chart.result[0].meta.regularMarketPrice); console.log(wtiUsdRaw); const wtiUsdTypeIntScaled = Math.round(wtiUsdRaw*100); console.log(wtiUsdTypeIntScaled); return Functions.encodeString(wtiUsdTypeIntScaled.toString());"
        // "// Test in :"
        // "// https://functions.chain.link/playground"
        // "const apiResponse = await Functions.makeHttpRequest({"
        // "  url: `https://query1.finance.yahoo.com/v8/finance/chart/CL=F`"
        // "})"
        // "if (apiResponse.error) {"
        // "  console.error(apiResponse.error)"
        // "  throw Error('Request failed');"
        // "}"
        // "const { data } = apiResponse;"
        // "console.log('API response data:');"
        // "const wtiUsdRaw = (data.chart.result[0].meta.regularMarketPrice);"
        // "console.log(wtiUsdRaw);"
        // "const wtiUsdTypeIntScaled = Math.round(wtiUsdRaw*100);"
        // "console.log(wtiUsdTypeIntScaled);"
        // "return Functions.encodeString(wtiUsdTypeIntScaled.toString());"
        // "// Format the Function script with the following "
        // "// tool to add quotes for each line for Solidity:"
        // "// https://onlinetexttools.com/add-quotes-to-lines"
    ;

    //Callback gas limit
    uint32 constant gasLimit = 300000;

    // donID - Hardcoded for Sepolia
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 constant donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    // State variable to store the returned character information
    string public wtiPriceOracle; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price

    /**
     * @notice Sends an HTTP request for character information
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(javascriptSourceCode); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        wtiPriceOracle = string(response);
        s_lastError = err;

        // Emit an event to log the response
        emit Response(requestId, wtiPriceOracle, s_lastResponse, s_lastError);
    }

    // Chainlink Keepers logic from the original contract with 

    // function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
    //     upkeepNeeded = ( 
    //         ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) 
    //         && 
    //         (IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this)) >= (0.01 ether) ) 
    //     );
    // }

    // function performUpkeep(bytes calldata) external override {
    //     // chainlinkNodeRequestWtiPrice();
    // }

    // function manualUpKeep() public {
    //     if(false == ( 
    //         ( block.timestamp >= (lastWtiPriceCheckUnixTime + 86400) ) 
    //         && 
    //         (IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this)) >= (0.01 ether) ) )) 
    //         revert upKeepNotNeeded(); 
    //     // chainlinkNodeRequestWtiPrice();
    // }

}
