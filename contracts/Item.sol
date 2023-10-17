// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Item is ERC721URIStorage {

    address immutable itemFactory;

    constructor(string memory name_, string memory symbol_, address itemFactory_) ERC721(name_, symbol_) {
        itemFactory = itemFactory_;
    }

    modifier onlyFactory() {
        require(msg.sender == itemFactory, "Only factory can call this function");
        _;
    }

    function batchMint(address to_, uint256 totalSupply_, string memory tokenURI_) public onlyFactory() {
        for(uint256 i = 1; i <= totalSupply_; i++) {
            _mint(to_, i);
            _setTokenURI(i, tokenURI_);
        }
    }
}