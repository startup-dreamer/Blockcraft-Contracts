// SPDX-License-Identifier: MIT
// This SPDX-License-Identifier indicates the license type under which the contract code is released.
pragma solidity ^0.8.20;

// Importing OpenZeppelin ERC721 and ERC721URIStorage contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Levels is ERC721, ERC721URIStorage {
    using Strings for string;
    // Using OpenZeppelin's Strings library for string operations

    uint256 immutable maxLevelCounter;
    // Maximum allowed level count, set during contract deployment and cannot be changed later

    uint256 public totalLevelCounter; 
    // Counter for generating unique level IDs across all users
    
    mapping(address => uint256) public userLevelCounter;
    // Counter for generating unique level IDs for each user
    
    mapping(address => uint256[]) public userLevelIds; 
    // Mapping of user addresses to arrays of their level IDs

    event LevelCreated(address indexed owner, uint256 indexed levelId, string indexed levelURI);
    // Event emitted when a level is created

    constructor(string memory name_, string memory symbol_, uint256 maxLevelCounter_) ERC721(name_, symbol_) {
        maxLevelCounter = maxLevelCounter_;
    }

    modifier isLevelOwner(uint256 userLevelIds_) {
        require(ownerOf(userLevelIds_) == msg.sender, "You are not the owner of this token");
        _;
    }

    function createLevel(string memory tokenURI_) public {
        require(userLevelCounter[msg.sender] < maxLevelCounter, "Max level count reached");
        // Check if the user has reached their maximum level count
        
        userLevelCounter[msg.sender] += 1; // Increment the user's level counter
        totalLevelCounter += 1; // Increment the total level counter

        _safeMint(msg.sender, totalLevelCounter); // Mint a new token
        _setTokenURI(totalLevelCounter, tokenURI_); // Set the token URI

        userLevelIds[msg.sender].push(totalLevelCounter); // Add the level ID to the user's array

        emit LevelCreated(msg.sender, totalLevelCounter, tokenURI_);
    }

    function fetchUserLevel(address user_) public view returns (string memory) {
        uint256 userLevel = userLevelCounter[user_]; // Get the user's level counter
        uint256 levelId = userLevelIds[user_][userLevel - 1]; // Get the corresponding level ID
        string memory tokenMetadata;
        string memory ipfsCid = tokenURI(levelId);
        string memory name = name();
        string memory userLevelStr = Strings.toString(userLevel);
        name = concatStrings(name, userLevelStr);
        
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"',
                        name,
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

    function getOwnerLevelId(address user_) public view returns (uint256) {
        uint256 userLevel = userLevelCounter[user_];
        return userLevel;
    }

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

    function concatStrings(string memory a, string memory b) internal pure returns (string memory) {
        bytes memory bytesA = bytes(a);
        bytes memory bytesB = bytes(b);
        string memory concatenatedString = new string(bytesA.length + bytesB.length);
        bytes memory bytesConcatenated = bytes(concatenatedString);
        
        uint k = 0;
        for (uint i = 0; i < bytesA.length; i++) {
            bytesConcatenated[k++] = bytesA[i];
        }
        
        for (uint i = 0; i < bytesB.length; i++) {
            bytesConcatenated[k++] = bytesB[i];
        }
        
        return string(bytesConcatenated);
    }
}
