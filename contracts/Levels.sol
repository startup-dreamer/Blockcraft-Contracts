// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Levels is ERC721, ERC721URIStorage {
    uint256 immutable maxLevelCounter;
    uint256 public totalLevelCounter; // Counter for generating unique level IDs
    mapping(address => uint256) public userLevelCounter; // Counter for generating unique level IDs
    mapping(address => uint256[]) public userLevelIds; 

    event LevelCreated(address indexed owner, uint256 indexed levelId, string indexed levelURI); // Event emitted when a level is created

    constructor(string memory name_, string memory symbol_, uint256 maxLevelCounter_) ERC721(name_, symbol_) {
        maxLevelCounter = maxLevelCounter_;
    }

    modifier isLevelOwner(uint256 userLevelIds_) {
        require(ownerOf(userLevelIds_) == msg.sender, "You are not the owner of this token");
        _;
    }

    function createLevel(string memory tokenURI_,) public {
        require(userLevelCounter[msg.sender] <= maxLevelCounter, "Max level count reached");
        userLevelCounter[msg.sender] += 1;
        totalLevelCounter += 1;
        _safeMint(msg.sender, totalLevelCounter);
        _setTokenURI(totalLevelCounter, tokenURI_);

        userLevelIds[msg.sender].push(totalLevelCounter);

        emit LevelCreated(msg.sender, totalLevelCounter, tokenURI_);
    }

    /**
     * @dev Fetches metadata for worlds owned by a specific user
     * @param user_ The address of the user/owner
     * @return An array of JSON strings representing the metadata of the worlds
     */
    function fetchUserLevel(address user_) public view returns (string memory) {
        uint256 userLevel = userLevelCounter[user_];
        uint256 levelId = userLevelIds[user_][userLevel - 1];
        string memory ipfsCid = tokenURI(levelId);
        // string memory name = userWorlds[i].worldName;
        // string memory description = userWorlds[i].worldDescription;
        string memory tokenMetadata;
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"',
                        // name,
                        '"' ", " '"description": ',
                        '"',
                        // description,
                        '"' ", " '"cid": ',
                        '"',
                        ipfsCid,
                        '"}'
                    )
                )
            )
        );
        tokenMetadata = string(abi.encodePacked(json));

        return tokenMetadata;
    }

    /**
     * @dev Returns an array of world IDs owned by a specific user
     * @param user_ The address of the user/owner
     * @return An array of world IDs
     */
    function getOwnerLevelId(address user_) public view returns (uint256) {
        uint256 userLevel = userLevelCounter[user_];
        return userLevel;
    }

    /**
     * @dev Returns the token URI for a given world
     * @param userLevelIds_ The ID of the world
     * @return The URI of the world's metadata
     */
    function tokenURI(uint256 userLevelIds_)
        public
        view
        override(ERC721, ERC721URIStorage)
        isLevelOwner(userLevelIds_)
        returns (string memory)
    {
        return super.tokenURI(userLevelIds_);
    }

    // Function to ensure compatibility with ERC721 interfaces
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
