// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../lib/reactive-lib/src/abstract-base/AbstractCallback.sol";

/**
 * @title DestinationContract
 * @notice 回调接收合约 - 部署在目标链上，接收来自 Reactive Network 的回调
 */
contract DestinationContract is AbstractCallback {
    event CallbackReceived(
        address indexed origin,
        address indexed sender,
        address indexed reactive_sender
    );

    constructor(address _callback_sender) AbstractCallback(_callback_sender) payable {}

    function callback(address sender)
        external
        authorizedSenderOnly
        rvmIdOnly(sender)
    {
        emit CallbackReceived(
            tx.origin,
            msg.sender,
            sender
        );
    }
}
