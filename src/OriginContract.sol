// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title OriginContract
 * @notice 事件源合约 - 部署在源链上，接收 ETH 并触发事件
 */
contract OriginContract {
    event Received(
        address indexed origin,
        address indexed sender,
        uint256 indexed value
    );

    receive() external payable {
        emit Received(
            tx.origin,
            msg.sender,
            msg.value
        );
        payable(tx.origin).transfer(msg.value);
    }
}
