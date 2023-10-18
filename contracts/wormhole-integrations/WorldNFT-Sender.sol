// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";
import "wormhole-solidity-sdk/WormholeRelayerSDK.sol";

contract HelloWormholeProtections is Base, IWormholeReceiver {
    event GreetingReceived(string greeting, uint16 senderChain, address sender);

    uint256 constant GAS_LIMIT = 50_000;


    constructor(address _wormholeRelayer, address _wormhole) Base(_wormholeRelayer, _wormhole) {}

    function quoteCrossChainGreeting(uint16 targetChain) public view returns (uint256 cost) {
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(targetChain, 0, GAS_LIMIT);
    }

    function sendCrossChainData(uint16 targetChain_, address targetAddress_, bytes memory data_, uint256 senderMsgValue_) public payable {
        uint256 cost = quoteCrossChainGreeting(targetChain);
        require(msg.value == cost, "Not enough value to fullfil gas fees");
        wormholeRelayer.sendPayloadToEvm{value: cost}(
            targetChain,
            targetAddress,
            abi.encode(data, msg.sender), // payload
            senderMsgValue_,
            GAS_LIMIT
        );
    }

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
        isRegisteredSender(sourceChain, sourceAddress)
        replayProtect(deliveryHash)
    {
        (bytes memory data, address sender) = abi.decode(payload, (string, address));

    }
}