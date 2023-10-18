// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";
import "wormhole-solidity-sdk/WormholeRelayerSDK.sol";

contract WorldNFTSender is Base, IWormholeReceiver {
    event GreetingReceived(string greeting, uint16 senderChain, address sender);

    uint256 constant GAS_LIMIT = 50_000;

    constructor(address _wormholeRelayer, address _wormhole) Base(_wormholeRelayer, _wormhole) {}

    function receiveWormholeMessages(
        bytes memory payload_,
        bytes[] memory, // additionalVaas
        bytes32 sourceAddress_,
        uint16 sourceChain_,
        bytes32 deliveryHash_
    )
        public
        payable
        override
        onlyWormholeRelayer
        isRegisteredSender(sourceChain_, sourceAddress_)
        replayProtect(deliveryHash_)
    {
        (bytes memory data, address sender) = abi.decode(payload_, (bytes, address));

    }
}