// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@scroll-tech/contracts/libraries/IScrollMessenger.sol";

// The WorldNFTOperator is a contract capable of executing functions on the WorldNFT contract through the bridge
contract WorldNFTOperator {
    // Immutable addresses for WorldNFT and ScrollMessenger contracts
    address immutable _worldNFT;
    address immutable _scrollMessenger;

    // Gas limit for crosschain function execution
    uint32 constant GAS_LIMIT = 50_000;

    // Constructor to set initial values
    constructor(address worldNFT_, address scrollMessenger_) {
        _worldNFT = worldNFT_;
        _scrollMessenger = scrollMessenger_;
    }

    // Function to create a new world
    function createWorld(string memory name_, string memory tokenURI_, string memory description_) public {
        // Encode function signature and parameters
        bytes memory createWorldSig =
            abi.encodeWithSignature("createWorld(string,string,string)", name_, tokenURI_, description_);
        // Execute function crosschain
        executeFunctionCrosschain(0, createWorldSig);
    }

    // Function to update the token URI of a world
    function updateTokenURI(address user_, uint256 worldId_, string memory tokenURI_) public {
        // Encode function signature and parameters
        bytes memory updateTokenURISig =
            abi.encodeWithSignature("createWorld(address,uint256,string)", user_, worldId_, tokenURI_);
        // Execute function crosschain
        executeFunctionCrosschain(0, updateTokenURISig);
    }

    // Function to execute a function on a different chain
    function executeFunctionCrosschain(uint256 value_, bytes memory data_) public payable {
        // Get the Scroll Messenger contract
        IScrollMessenger scrollMessenger = IScrollMessenger(_scrollMessenger);
        // sendMessage is able to execute any function by encoding the abi using the encodeWithSignature function
        scrollMessenger.sendMessage{value: msg.value}(_worldNFT, value_, data_, GAS_LIMIT, msg.sender);
    }
}