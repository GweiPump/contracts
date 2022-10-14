// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract VockTails is VRFConsumerBaseV2 {

  VRFCoordinatorV2Interface public COORDINATOR;
  LinkTokenInterface public LINKTOKEN;

  uint public requestId;
  uint[] public oneRandomWord;

  event drinkVRF();

  constructor() VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed) {
    COORDINATOR = VRFCoordinatorV2Interface(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed);
    LINKTOKEN = LinkTokenInterface(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
  }

  function requestRandomWords() external { //https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#polygon-matic-mumbai-testnet
      requestId = COORDINATOR.requestRandomWords(
      0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f, //keyHash
      2217,     //subscriptionId [Get your ID here https://vrf.chain.link/]
      3,        //Confirmations
      2500000,  //callbackGasLimit
      1         //numWords
    );
  }

  function fulfillRandomWords(uint,  uint[] memory randomWords) internal override {
    oneRandomWord = randomWords; //drinkValue = (oneRandomWord[0] % 3), compute off chain to save gas.; //Drink values 0 [one], 1 [two] and 2 [mixed].
    emit drinkVRF();
  }

}
