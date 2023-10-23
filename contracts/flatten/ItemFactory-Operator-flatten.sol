// Sources flattened with hardhat v2.17.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @scroll-tech/contracts/libraries/IScrollMessenger.sol@v0.1.0

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.16;

interface IScrollMessenger {
    /**********
     * Events *
     **********/

    /// @notice Emitted when a cross domain message is sent.
    /// @param sender The address of the sender who initiates the message.
    /// @param target The address of target contract to call.
    /// @param value The amount of value passed to the target contract.
    /// @param messageNonce The nonce of the message.
    /// @param gasLimit The optional gas limit passed to L1 or L2.
    /// @param message The calldata passed to the target contract.
    event SentMessage(
        address indexed sender,
        address indexed target,
        uint256 value,
        uint256 messageNonce,
        uint256 gasLimit,
        bytes message
    );

    /// @notice Emitted when a cross domain message is relayed successfully.
    /// @param messageHash The hash of the message.
    event RelayedMessage(bytes32 indexed messageHash);

    /// @notice Emitted when a cross domain message is failed to relay.
    /// @param messageHash The hash of the message.
    event FailedRelayedMessage(bytes32 indexed messageHash);

    /*************************
     * Public View Functions *
     *************************/

    /// @notice Return the sender of a cross domain message.
    function xDomainMessageSender() external view returns (address);

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Send cross chain message from L1 to L2 or L2 to L1.
    /// @param target The address of account who receive the message.
    /// @param value The amount of ether passed when call target contract.
    /// @param message The content of the message.
    /// @param gasLimit Gas limit required to complete the message relay on corresponding chain.
    function sendMessage(
        address target,
        uint256 value,
        bytes calldata message,
        uint256 gasLimit
    ) external payable;

    /// @notice Send cross chain message from L1 to L2 or L2 to L1.
    /// @param target The address of account who receive the message.
    /// @param value The amount of ether passed when call target contract.
    /// @param message The content of the message.
    /// @param gasLimit Gas limit required to complete the message relay on corresponding chain.
    /// @param refundAddress The address of account who will receive the refunded fee.
    function sendMessage(
        address target,
        uint256 value,
        bytes calldata message,
        uint256 gasLimit,
        address refundAddress
    ) external payable;
}


// File contracts/Scroll-CrossChain/ItemFactory-Operator.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.16;

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
