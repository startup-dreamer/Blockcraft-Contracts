// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./item.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ItemFactory {
    using Counters for Counters.Counter;

    /**
     * ========================================================= *
     *                   Storage Declarations                    *
     * ========================================================= *
     */

    Counters.Counter public _totalItems;

    uint256 private constant MAX_INT = 2**256 - 1;

    struct ItemOnMarketplace {
        bool listing;
        uint256 price;
        uint256 totalSupply;
        uint256 totalSold;
        address itemAddress;
        address creator;
        string tokenURI;
        string tokenName;
    }

    mapping(uint256 => ItemOnMarketplace) public itemNumToItem;

    event ItemCreated(string indexed name, string indexed  uri, uint256 indexed totalSupply);
    event ItemSold(uint256 indexed itemNum, uint256 tokenId, address indexed tokenAddress);

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
     * @param tokenURI_ The tokenURI of the item
     * @return The token number of the newly created item
     */
    function newItem(
        uint256 totalSupply_,
        string memory name_,
        string memory symbol_,
        string memory tokenURI_
    ) public returns (uint256) {
        _totalItems.increment();
        uint256 newItemNum = _totalItems.current();

        Item item = new Item(name_, symbol_, address(this));
        item.batchMint(address(this), totalSupply_, tokenURI_);

        ItemOnMarketplace memory tmp = ItemOnMarketplace({
            listing: false,
            price: MAX_INT,
            totalSupply: totalSupply_,
            totalSold: 0,
            creator: msg.sender,
            itemAddress: address(item),
            tokenURI: tokenURI_,
            tokenName: name_
        });

        itemNumToItem[newItemNum] = tmp;

        emit ItemCreated(name_, tokenURI_, totalSupply_);
        return newItemNum;
    }

    /**
     * @dev Lists the item on marketplace
     * @param itemNum_ The token number of the item
     * @param price_ The price of the item
     */
    function listOnMarketplace(uint256 itemNum_, uint256 price_) public {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(
            itemStruct.creator == msg.sender,
            "Only owner can list the token on marketplace"
        );
        itemStruct.listing = true;
        itemStruct.price = price_;
    }

    /**
     * @dev Removes the item from marketplace
     * @param itemNum_ The token number of the item
     */
    function removeFromMarketplace(uint256 itemNum_) public {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(
            itemStruct.creator == msg.sender,
            "Only owner can remove the token from marketplace"
        );
        itemStruct.listing = false;
        itemStruct.price = MAX_INT;
    }

    /** 
     * @dev Purchase the item from marketplace
     * @param itemNum_ The token number of the item
     */
    function purchase(uint256 itemNum_) public payable {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.listing, "The token is not listed");
        require(msg.value == itemStruct.price, "The price is not correct");

        uint256 tokenId_ = itemStruct.totalSold + 1;

        // Transfer the token
        Item(itemStruct.itemAddress).transferFrom(address(this), msg.sender, tokenId_);

        // Update marketplace to remove the listing
        itemStruct.totalSold += 1;

        // handeling the case when all tokens are sold.
        if(itemStruct.totalSold == itemStruct.totalSupply) {
            itemStruct.listing = false;
            itemStruct.price = MAX_INT;
        }
        emit ItemSold(itemNum_, tokenId_, itemStruct.itemAddress);
    }
}