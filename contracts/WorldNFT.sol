// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract WorldNFT is ERC721, ERC721URIStorage {
    uint256 public worldIdCounter;

    struct WorldInfo {
        string worldName;
        string worldDescription;
    }
    mapping(address => WorldInfo[]) public userWorldInfo;
    mapping(address => uint256[]) public userWorldIds;

    event WorldCreated(address indexed owner, uint256 indexed worldId, string indexed worldURI);
    event UpdatedWorldURI(address indexed owner, uint256 indexed worldId, string indexed worldURI);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    modifier isWorldOwner(uint256 worldId_) {
        require(ownerOf(worldId_) == msg.sender, "You are not the owner of this token");
        _;
    }

    modifier isUserTokenExists(address user_, uint256 worldId_) {
        uint256[] memory worldIds = userWorldIds[user_];
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

    function createWorld(string memory name_, string memory tokenURI_, string memory description_) public {
        worldIdCounter += 1;
        _safeMint(msg.sender, worldIdCounter);
        _setTokenURI(worldIdCounter, tokenURI_);
        
        WorldInfo memory worldInfo = WorldInfo({
            worldName: name_,
            worldDescription: description_
        });

        userWorldInfo[msg.sender].push(worldInfo);
        userWorldIds[msg.sender].push(worldIdCounter);

        emit WorldCreated(msg.sender, worldIdCounter, tokenURI_);
    }

    function tokenURI(uint256 worldId_) public view override(ERC721, ERC721URIStorage) isWorldOwner(worldId_) returns (string memory) {
        return super.tokenURI(worldId_);
    }

    function fetchMetadata(address user_) public view returns (string[] memory) {
        uint256[] memory worldIds = userWorldIds[user_];
        WorldInfo[] memory userWorlds = userWorldInfo[user_];
        uint256 worldIdLength = worldIds.length;
        string[] memory tokenMetadata = new string[](worldIdLength);

        for(uint256 i = 0; i < worldIdLength; i++) {
            string memory ipfsCid = tokenURI(worldIds[i]);
            string memory name = userWorlds[i].worldName;
            string memory description = userWorlds[i].worldDescription;
            string memory json = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": ', '"', name, '"' ', '
                            '"description": ', '"',  description, '"' ', '
                            '"cid": ', '"', ipfsCid,
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
        uint256[] memory worldIds = userWorldIds[user_];
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
