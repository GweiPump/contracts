// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IGweiPump {
    // custom errors
    error pumpNotFilled();
    error msgValueTooSmall();
    error oraclePriceFeedZero();
    error upKeepNotNeeded();
    error etherNotSent();
    error UnexpectedRequestID(bytes32 requestId);

    // events
    event oilBought();
    event updateWti();
    event Response(
        bytes32 indexed requestId,
        string value,
        bytes response,
        bytes err
    );
}