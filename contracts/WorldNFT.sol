// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract WorldNFT is ERC721, ERC721URIStorage {
    uint256 public worldIdCounter; // Counter for generating unique world IDs

    struct WorldInfo {
        string worldName; // Name of the world
        string worldDescription; // Description of the world
    }

    // Mapping of user addresses to arrays of WorldInfo and world IDs
    mapping(address => WorldInfo[]) public userWorldInfo;
    mapping(address => uint256[]) public userWorldIds;

    event WorldCreated(address indexed owner, uint256 indexed worldId, string indexed worldURI); // Event emitted when a world is created
    event UpdatedWorldURI(address indexed owner, uint256 indexed worldId, string indexed worldURI); // Event emitted when the world URI is updated

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    // Modifier to check if the caller is the owner of the specified world
    modifier isWorldOwner(uint256 worldId_) {
        require(ownerOf(worldId_) == msg.sender, "You are not the owner of this token");
        _;
    }

    // Modifier to check if the specified world ID exists for the caller
    modifier isUserTokenExists(address user_, uint256 worldId_) {
        uint256[] memory worldIds = userWorldIds[user_];
        bool exists = false;

        for (uint256 i = 0; i < worldIds.length; i++) {
            if (worldIds[i] == worldId_) {
                exists = true;
                break;
            }
        }

        require(exists, "Token does not exist for this user");
        _;
    }

    /**
     * @dev Creates a new world and mints an NFT for it
     * @param name_ The name of the world
     * @param tokenURI_ The URI for the world's metadata
     * @param description_ The description of the world
     */
    function createWorld(string memory name_, string memory tokenURI_, string memory description_) public {
        worldIdCounter += 1;
        _safeMint(msg.sender, worldIdCounter);
        _setTokenURI(worldIdCounter, tokenURI_);

        WorldInfo memory worldInfo = WorldInfo({worldName: name_, worldDescription: description_});

        userWorldInfo[msg.sender].push(worldInfo);
        userWorldIds[msg.sender].push(worldIdCounter);

        emit WorldCreated(msg.sender, worldIdCounter, tokenURI_);
    }

    /**
     * @dev Returns the token URI for a given world
     * @param worldId_ The ID of the world
     * @return The URI of the world's metadata
     */
    function tokenURI(uint256 worldId_)
        public
        view
        override(ERC721, ERC721URIStorage)
        isWorldOwner(worldId_)
        returns (string memory)
    {
        return super.tokenURI(worldId_);
    }

    /**
     * @dev Fetches metadata for worlds owned by a specific user
     * @param user_ The address of the user/owner
     * @return An array of JSON strings representing the metadata of the worlds
     */
    function fetchMetadata(address user_) public view returns (string[] memory) {
        uint256[] memory worldIds = userWorldIds[user_];
        WorldInfo[] memory userWorlds = userWorldInfo[user_];
        uint256 worldIdLength = worldIds.length;
        string[] memory tokenMetadata = new string[](worldIdLength);

        for (uint256 i = 0; i < worldIdLength; i++) {
            string memory ipfsCid = tokenURI(worldIds[i]);
            string memory name = userWorlds[i].worldName;
            string memory description = userWorlds[i].worldDescription;
            string memory json = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": ',
                            '"',
                            name,
                            '"' ", " '"description": ',
                            '"',
                            description,
                            '"' ", " '"cid": ',
                            '"',
                            ipfsCid,
                            '"}'
                        )
                    )
                )
            );
            tokenMetadata[i] = string(abi.encodePacked(json));
        }

        return tokenMetadata;
    }

    /**
     * @dev Returns an array of world IDs owned by a specific user
     * @param user_ The address of the user/owner
     * @return An array of world IDs
     */
    function getOwnerWorldIds(address user_) public view returns (uint256[] memory) {
        uint256[] memory worldIds = userWorldIds[user_];
        return worldIds;
    }

    /**
     * @dev Updates the token URI for a specific world
     * @param user_ The address of the user/owner
     * @param worldId_ The ID of the world
     * @param tokenURI_ The new URI for the world's metadata
     */
    function updateTokenURI(address user_, uint256 worldId_, string memory tokenURI_)
        public
        isWorldOwner(worldId_)
        isUserTokenExists(user_, worldId_)
    {
        super._setTokenURI(worldId_, tokenURI_);

        emit UpdatedWorldURI(user_, worldId_, tokenURI_);
    }

    // Function to ensure compatibility with ERC721 interfaces
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
