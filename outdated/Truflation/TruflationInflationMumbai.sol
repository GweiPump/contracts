// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.17;

// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

// contract TruflationTester is ChainlinkClient { //Modified from: https://goerli.etherscan.io/address/0x92733D7Da602A9A1415249F1729CBB732330d109#code 
                                               
//   using Chainlink for Chainlink.Request;

//   address public constant oracleId = 0x6D141Cf6C43f7eABF94E288f5aa3f23357278499; //MUMBAI 
//   string  public  constant  jobId = "d220e5e687884462909a03021385b7ae"; //MUMBAI
//   uint256 public constant fee = 1 ether; 
//   string public yoyInflation;

//   constructor() {
//     setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
//   }

//   function requestYoyInflation() public returns (bytes32 requestId) {
//     Chainlink.Request memory req = buildChainlinkRequest(
//       bytes32(bytes(jobId)),
//       address(this),
//       this.fulfillYoyInflation.selector
//     );
//     req.add("service", "truflation/current");
//     req.add("keypath", "yearOverYearInflation");
//     req.add("abi", "json");
//     return sendChainlinkRequestTo(oracleId, req, fee);
//   }

//   function fulfillYoyInflation(
//     bytes32 _requestId,
//     bytes memory _inflation
//   ) public recordChainlinkFulfillment(_requestId) {
//     yoyInflation = string(_inflation);
//   }

// /*
//   // The following are for retrieving inflation in terms of wei
//   // This is useful in situations where you want to do numerical
//   // processing of values within the smart contract

//   // This will require a int256 rather than a uint256 as inflation
//   // can be negative

//   int256 public inflationWei;
//   function requestInflationWei() public returns (bytes32 requestId) {
//     Chainlink.Request memory req = buildChainlinkRequest(
//       bytes32(bytes(jobId)),
//       address(this),
//       this.fulfillInflationWei.selector
//     );
//     req.add("service", "truflation/current");
//     req.add("keypath", "yearOverYearInflation");
//     req.add("abi", "int256");
//     req.add("multiplier", "1000000000000000000");
//     return sendChainlinkRequestTo(oracleId, req, fee);
//   }

//   function fulfillInflationWei(
//     bytes32 _requestId,
//     bytes memory _inflation
//   ) public recordChainlinkFulfillment(_requestId) {
//     inflationWei = toInt256(_inflation);
//   }

//   function toInt256(bytes memory _bytes) internal pure
//   returns (int256 value) {
//     assembly {
//       value := mload(add(_bytes, 0x20))
//     }
//   }
// */

// }
