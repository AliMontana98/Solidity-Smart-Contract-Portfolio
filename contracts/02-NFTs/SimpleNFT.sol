// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleNFT
 * @dev A basic ERC-721 NFT contract with owner-controlled minting.
 * @notice This contract allows only the owner to mint new NFTs.
 */
contract SimpleNFT is ERC721, Ownable {
    /// @dev Counter for tracking the next token ID to mint
    uint256 private _nextTokenId;

    /**
     * @dev Constructor that sets the NFT name and symbol.
     */
    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}

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
     * @dev Batch mints multiple NFTs to a single address.
     * @param to The address that will receive the minted NFTs.
     * @param quantity The number of NFTs to mint.
     * @notice Only the contract owner can call this function.
     */
    function batchMint(address to, uint256 quantity) public onlyOwner {
        require(quantity > 0, "Quantity must be greater than 0");
        require(quantity <= 100, "Cannot mint more than 100 at once");
        
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(to, tokenId);
        }
    }

    /**
     * @dev Returns the total number of tokens minted.
     * @return The total supply of minted tokens.
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}
