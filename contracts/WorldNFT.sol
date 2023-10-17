// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WorldNFT is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter public worldIdCounter;

    string public worldDescription;
    string public worldName;
    mapping(address => uint256[]) public ownerWorlds;

    event WorldCreated(address indexed owner, uint256 indexed worldId, string indexed worldURI);
    event UpdatedWorldURI(address indexed owner, uint256 indexed worldId, string indexed worldURI);

    constructor(string memory name_, string memory symbol_, string memory description_) ERC721(name_, symbol_) {
        worldDescription = description_;
        worldName = name_;
    }

    modifier isWorldOwner(uint256 worldId_) {
        require(ownerOf(worldId_) == msg.sender, "You are not the owner of this token");
        _;
    }

    modifier isUserTokenExists(address user_, uint256 worldId_) {
        uint256[] memory worldIds = ownerWorlds[user_];
        bool exists = false;

        for(uint256 i = 0; i < worldIds.length; i++) {
            if (worldIds[i] == worldId_) {
                exists = true;
                break;
            }
        }

        require(exists, "Token does not exist for this user");
        _;
    }

    function createWorld(string memory tokenURI_) public {
        worldIdCounter.increment();
        uint256 newworldId = worldIdCounter.current();
        _safeMint(msg.sender, newworldId);
        ownerWorlds[msg.sender].push(newworldId);
        _setTokenURI(newworldId, tokenURI_);

        emit WorldCreated(msg.sender, newworldId, tokenURI_);
    }

    function tokenURI(uint256 worldId_) public view override(ERC721, ERC721URIStorage) isWorldOwner(worldId_) returns (string memory) {
        return super.tokenURI(worldId_);
    }

    function fetchMetadata(address user_) public view returns (string[] memory) {
        uint256[] memory worldIds = ownerWorlds[user_];
        uint256 worldIdLength = worldIds.length;
        string[] memory tokenMetadata = new string[](worldIdLength);

        for(uint256 i = 0; i < worldIdLength; i++) {
            string memory ipfsCid = tokenURI(worldIds[i]);
            string memory json = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": worldName,',
                            '"description": worldDescription,',
                            '"cid": ', ipfsCid,
                            '"}'
                        )
                    )
                )
            );
            tokenMetadata[i] = string(abi.encodePacked(json));
        }

        return tokenMetadata;
    }

    function getOwnerWorldIds(address user_) view public returns(uint256[] memory) {
        uint256[] memory worldIds = ownerWorlds[user_];
        return worldIds;
    }

    function updateTokenURI(address user_, uint256 worldId_, string memory tokenURI_) public isWorldOwner(worldId_) isUserTokenExists(user_, worldId_) {
        super._setTokenURI(worldId_, tokenURI_);
        
        emit UpdatedWorldURI(user_, worldId_, tokenURI_);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
