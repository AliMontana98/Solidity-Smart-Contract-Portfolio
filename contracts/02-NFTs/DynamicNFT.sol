// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title DynamicNFT
 * @dev ERC-721 NFT with updatable metadata (tokenURI).
 * @notice This contract allows the owner to update the metadata URI
 * of individual tokens after minting, enabling dynamic NFTs.
 */
contract DynamicNFT is ERC721, Ownable {
    using Strings for uint256;

    /// @dev Counter for tracking the next token ID to mint
    uint256 private _nextTokenId;

    /// @dev Base URI for token metadata
    string private _baseTokenURI;

    /// @dev Mapping from token ID to custom token URI (if set)
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev Emitted when a token's URI is updated.
     */
    event TokenURIUpdated(uint256 indexed tokenId, string newURI);

    /**
     * @dev Constructor that sets the NFT name and symbol.
     */
    constructor() ERC721("DynamicNFT", "DNFT") Ownable(msg.sender) {}

    /**
     * @dev Mints a new NFT to the specified address.
     * @param to The address that will receive the minted NFT.
     * @return tokenId The ID of the newly minted token.
     * @notice Only the contract owner can call this function.
     */
    function mint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    /**
     * @dev Mints a new NFT with a custom tokenURI.
     * @param to The address that will receive the minted NFT.
     * @param customURI The custom metadata URI for this token.
     * @return tokenId The ID of the newly minted token.
     * @notice Only the contract owner can call this function.
     */
    function mintWithURI(address to, string memory customURI) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, customURI);
        return tokenId;
    }

    /**
     * @dev Updates the tokenURI for an existing token.
     * @param tokenId The ID of the token to update.
     * @param newURI The new metadata URI.
     * @notice Only the contract owner can call this function.
     * The token must exist.
     */
    function updateTokenURI(uint256 tokenId, string memory newURI) public onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        _setTokenURI(tokenId, newURI);
    }

    /**
     * @dev Batch updates tokenURIs for multiple tokens.
     * @param tokenIds Array of token IDs to update.
     * @param newURIs Array of new URIs corresponding to each token ID.
     * @notice Only the contract owner can call this function.
     * Arrays must have the same length.
     */
    function batchUpdateTokenURI(
        uint256[] calldata tokenIds,
        string[] calldata newURIs
    ) public onlyOwner {
        require(tokenIds.length == newURIs.length, "Arrays length mismatch");
        require(tokenIds.length > 0, "Empty arrays");
        require(tokenIds.length <= 50, "Too many updates at once");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(_ownerOf(tokenIds[i]) != address(0), "Token does not exist");
            _setTokenURI(tokenIds[i], newURIs[i]);
        }
    }

    /**
     * @dev Sets the base URI for all token metadata.
     * @param baseURI The base URI string.
     * @notice Only the contract owner can call this function.
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    /**
     * @dev Internal function to set a custom tokenURI.
     * @param tokenId The token ID to set the URI for.
     * @param customURI The custom URI string.
     */
    function _setTokenURI(uint256 tokenId, string memory customURI) internal {
        _tokenURIs[tokenId] = customURI;
        emit TokenURIUpdated(tokenId, customURI);
    }

    /**
     * @dev Returns the URI for a given token ID.
     * @param tokenId The token ID to query.
     * @return The token's metadata URI.
     * @notice If a custom URI is set, it returns that; otherwise, it uses baseURI + tokenId.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        string memory customURI = _tokenURIs[tokenId];
        
        // If custom URI is set, return it
        if (bytes(customURI).length > 0) {
            return customURI;
        }

        // Otherwise, use baseURI + tokenId
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : "";
    }

    /**
     * @dev Returns the base URI for token metadata.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Returns the total number of tokens minted.
     * @return The total supply of minted tokens.
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}
