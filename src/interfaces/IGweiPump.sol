// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IGweiPump {
    // custom errors
    error pumpNotFilled();
    error msgValueTooSmall();
    error oraclePriceFeedZero();
    error upKeepNotNeeded();
    error etherNotSent();

    // events
    event oilBought();
    event updateWti();
}