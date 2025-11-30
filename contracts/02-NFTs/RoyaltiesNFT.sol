// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RoyaltiesNFT
 * @dev ERC-721 NFT with EIP-2981 royalty standard implementation.
 * @notice This contract allows creators to set on-chain royalty fees for secondary sales.
 */
contract RoyaltiesNFT is ERC721, ERC2981, Ownable {
    /// @dev Counter for tracking the next token ID to mint
    uint256 private _nextTokenId;

    /// @dev Base URI for token metadata
    string private _baseTokenURI;

    /**
     * @dev Constructor that sets the NFT name, symbol, and default royalty.
     * @param defaultRoyaltyReceiver Address that will receive royalty payments.
     * @param defaultRoyaltyFraction Royalty percentage in basis points (e.g., 500 = 5%).
     */
    constructor(
        address defaultRoyaltyReceiver,
        uint96 defaultRoyaltyFraction
    ) ERC721("RoyaltiesNFT", "RNFT") Ownable(msg.sender) {
        require(defaultRoyaltyFraction <= 10000, "Royalty fraction too high");
        _setDefaultRoyalty(defaultRoyaltyReceiver, defaultRoyaltyFraction);
    }

    /**
     * @dev Mints a new NFT with default royalty settings.
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
     * @dev Mints a new NFT with custom royalty settings for this specific token.
     * @param to The address that will receive the minted NFT.
     * @param royaltyReceiver Address that will receive royalties for this token.
     * @param royaltyFraction Royalty percentage in basis points (e.g., 750 = 7.5%).
     * @return tokenId The ID of the newly minted token.
     * @notice Only the contract owner can call this function.
     */
    function mintWithRoyalty(
        address to,
        address royaltyReceiver,
        uint96 royaltyFraction
    ) public onlyOwner returns (uint256) {
        require(royaltyFraction <= 10000, "Royalty fraction too high");
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenRoyalty(tokenId, royaltyReceiver, royaltyFraction);
        
        return tokenId;
    }

    /**
     * @dev Updates the default royalty for all future mints.
     * @param receiver Address that will receive royalty payments.
     * @param feeNumerator Royalty percentage in basis points.
     * @notice Only the contract owner can call this function.
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        require(feeNumerator <= 10000, "Royalty fraction too high");
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @dev Sets the base URI for token metadata.
     * @param baseURI The base URI string.
     * @notice Only the contract owner can call this function.
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
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

    /**
     * @dev Override required by Solidity for multiple inheritance.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
