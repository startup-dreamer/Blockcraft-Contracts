// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Item.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ItemFactory {
    using Strings for string;

    /**
     * ========================================================= *
     *                   Storage Declarations                    *
     * ========================================================= *
     */

    uint256 public _totalItems; // Total number of items created

    uint256 private constant MAX_INT = 2 ** 256 - 1; // Maximum possible value for uint256

    struct ItemOnMarketplace {
        bool listing; // Indicates if the item is listed on the marketplace
        uint256 price; // Price of the item
        uint256 totalSupply; // Total supply of the item
        uint256 totalSold; // Total items sold
        address itemAddress; // Address of the item contract
        address creator; // Address of the creator
        string itemURI; // URI of the item
        string itemName; // Name of the item
    }

    mapping(uint256 => ItemOnMarketplace) public itemNumToItem; // Mapping of item number to item details
    mapping(address => address[]) public creatorToItemAddresses; // Mapping of creator address to their item addresses

    event ItemCreated(string indexed name, string indexed uri, uint256 indexed totalSupply); // Event emitted when an item is created
    event ItemSold(uint256 indexed itemNum, uint256 tokenId, address indexed tokenAddress); // Event emitted when an item is sold

    modifier isItemExists(string memory name_, string memory itemURI_) {
        // Check if an item with the same name or URI already exists
        for (uint256 i = 1; i <= _totalItems;) {
            require(!name_.equal(itemNumToItem[i].itemName), "Item exists");
            require(!itemURI_.equal(itemNumToItem[i].itemURI), "Item exists");
            unchecked {
                ++i;
            }
        }
        _;
    }

    /**
     * ========================================================= *
     *                      Public Function                      *
     * ========================================================= *
     */

    /**
     * @dev Creates a new Item
     * @param totalSupply_ The total supply of the item
     * @param name_ The name of the item
     * @param symbol_ The symbol of the item
     * @param itemURI_ The itemURI of the item
     * @return The token number of the newly created item
     */
    function newItem(uint256 totalSupply_, string memory name_, string memory symbol_, string memory itemURI_)
        public
        isItemExists(name_, itemURI_)
        returns (uint256)
    {
        _totalItems += 1;
        uint256 newItemNum = _totalItems;

        Item item = new Item(name_, symbol_, address(this));
        item.batchMint(address(this), totalSupply_, itemURI_);

        ItemOnMarketplace memory tmp = ItemOnMarketplace({
            listing: false,
            price: MAX_INT,
            totalSupply: totalSupply_,
            totalSold: 0,
            creator: msg.sender,
            itemAddress: address(item),
            itemURI: itemURI_,
            itemName: name_
        });

        creatorToItemAddresses[msg.sender].push(address(item));
        itemNumToItem[newItemNum] = tmp;

        emit ItemCreated(name_, itemURI_, totalSupply_);
        return newItemNum;
    }

    /**
     * @dev Lists the item on marketplace
     * @param itemNum_ The token number of the item
     * @param price_ The price of the item
     */
    function listOnMarketplace(uint256 itemNum_, uint256 price_) public {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.creator == msg.sender, "Only owner can list the token on marketplace");
        itemStruct.listing = true;
        itemStruct.price = price_;
    }

    /**
     * @dev Removes the item from marketplace
     * @param itemNum_ The token number of the item
     */
    function removeFromMarketplace(uint256 itemNum_) public {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.creator == msg.sender, "Only owner can remove the token from marketplace");
        itemStruct.listing = false;
        itemStruct.price = MAX_INT;
    }

    /**
     * @dev Purchase the item from marketplace
     * @param itemNum_ The token number of the item
     */
    function purchaseItem(uint256 itemNum_) public payable {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.listing, "The token is not listed");
        require(msg.value == itemStruct.price, "The price is not correct");

        uint256 tokenId_ = itemStruct.totalSold + 1;

        // Transfer the token
        Item(itemStruct.itemAddress).transferFrom(address(this), msg.sender, tokenId_);

        // Update marketplace to remove the listing
        itemStruct.totalSold += 1;

        // Handling the case when all tokens are sold.
        if (itemStruct.totalSold == itemStruct.totalSupply) {
            itemStruct.listing = false;
            itemStruct.price = MAX_INT;
        }
        emit ItemSold(itemNum_, tokenId_, itemStruct.itemAddress);
    }

    /**
     * @dev Fetches metadata for items created by a specific user
     * @param user_ The address of the user/creator
     * @return An array of JSON strings representing the metadata of the items
     */
    function fetchMetadata(address user_) public view returns (string[] memory) {
        address[] memory itemAddresses = creatorToItemAddresses[user_];
        uint256 itemAddressesLength = itemAddresses.length;
        string[] memory itemMetadata = new string[](itemAddressesLength);

        for (uint256 i = 0; i < itemAddressesLength; i++) {
            Item _item = Item(itemAddresses[i]);
            // Total number of items will have same uri hence 1.
            string memory ipfsCid = _item.tokenURI(1);
            string memory name = _item.name();
            string memory json = Base64.encode(
                bytes(string(abi.encodePacked('{"name": ', '"', name, '"' ", " '"cid": ', '"', ipfsCid, '"}')))
            );
            itemMetadata[i] = string(abi.encodePacked(json));
        }
        return itemMetadata;
    }
}
