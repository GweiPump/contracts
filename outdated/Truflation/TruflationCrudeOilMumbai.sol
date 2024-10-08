// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.17;

// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
// import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

// contract TruflationCrudeOilMumbai is ChainlinkClient {

//     uint public constant fee = 1 ether;   //1 LINK TOKEN
//     uint public result;
//     address public constant oracleId = 0x6D141Cf6C43f7eABF94E288f5aa3f23357278499; //MUMBAI 
//     string  public constant  jobId = "d220e5e687884462909a03021385b7ae"; //MUMBAI

//     using Chainlink for Chainlink.Request;

//     constructor() {
// 	    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //MUMBAI LINK TOKEN
//     }

//     function crudeOilRequestChainlinkTruflation() public returns (bytes32 requestId) {
//         Chainlink.Request memory req = buildChainlinkRequest(bytes32(bytes(jobId)), address(this), this.fulfillBytes.selector);
//         req.add("service", "truflation/current");
//         req.add("data", "{'id':'603'}");
//         // req.add("data", "{ ids: '603'}");
//         req.add("keypath", "value");
//         req.add("abi", "uint256");
//         req.add("multiplier", "10000000000000000000");
//         return sendChainlinkRequestTo(oracleId, req, fee);
//     }

//     function fulfillBytes(bytes32 _requestId, uint uintData) public recordChainlinkFulfillment(_requestId) {
//         result = uintData;
//     }

// }
