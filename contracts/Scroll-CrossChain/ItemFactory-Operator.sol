// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@scroll-tech/contracts@0.1.0/libraries/IScrollMessenger.sol";

contract ItemFactoryOperator {
    // Immutable addresses for Item Factory and Scroll Messenger contracts
    address immutable _itemFactory;
    address immutable _scrollMessenger;

    // Gas limit for crosschain function execution
    uint32 constant GAS_LIMIT = 50_000;

    // Constructor to set initial values
    constructor(address itemFactory_, address scrollMessenger_) {
        _itemFactory = itemFactory_;
        _scrollMessenger = scrollMessenger_;
    }

    // Function to create a new item
    function newItem(uint256 totalSupply_, string memory name_, string memory symbol_, string memory itemURI_) public {
        // Encode function signature and parameters
        bytes memory newItemSig =
            abi.encodeWithSignature("newItem(uint256,string,string,string)", totalSupply_, name_, symbol_, itemURI_);
        // Execute function crosschain
        executeFunctionCrosschain(0, newItemSig);
    }

    // Function to list an item on the marketplace
    function listOnMarketplace(uint256 itemNum_, uint256 price_) public {
        // Encode function signature and parameters
        bytes memory listOnMarketplaceSig =
            abi.encodeWithSignature("listOnMarketplace(uint256,uint256)", itemNum_, price_);
        // Execute function crosschain
        executeFunctionCrosschain(0, listOnMarketplaceSig);
    }

    // Function to remove an item listing from the marketplace
    function removeListing(uint256 itemNum_) public {
        // Encode function signature and parameters
        bytes memory removeListingSig = abi.encodeWithSignature("removeListing(uint256)", itemNum_);
        // Execute function crosschain
        executeFunctionCrosschain(0, removeListingSig);
    }

    // Function to purchase an item from the marketplace
    function purchaseItem(uint256 itemNum_) public payable {
        // Encode function signature and parameters
        bytes memory purchaseItemSig = abi.encodeWithSignature("purchaseItem(uint256)", itemNum_);
        // Execute function crosschain, passing the value sent with the transaction
        executeFunctionCrosschain(msg.value, purchaseItemSig);
    }

    // Function to execute a function on a different chain
    function executeFunctionCrosschain(uint256 value_, bytes memory data_) public payable {
        // Get the Scroll Messenger contract
        IScrollMessenger scrollMessenger = IScrollMessenger(_scrollMessenger);
        // sendMessage is able to execute any function by encoding the abi using the encodeWithSignature function
        scrollMessenger.sendMessage{value: msg.value}(_itemFactory, value_, data_, GAS_LIMIT, msg.sender);
    }
}
