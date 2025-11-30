// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SoulboundToken
 * @dev A non-transferable ERC-721 NFT (Soulbound Token).
 * @notice Once minted, these tokens cannot be transferred between addresses.
 * They are permanently bound to the recipient's address.
 */
contract SoulboundToken is ERC721, Ownable {
    /// @dev Counter for tracking the next token ID to mint
    uint256 private _nextTokenId;

    /// @dev Base URI for token metadata
    string private _baseTokenURI;

    /**
     * @dev Emitted when a soulbound token is minted.
     */
    event SoulboundTokenMinted(address indexed to, uint256 indexed tokenId);

    /**
     * @dev Constructor that sets the NFT name and symbol.
     */
    constructor() ERC721("SoulboundToken", "SBT") Ownable(msg.sender) {}

    /**
     * @dev Mints a new soulbound token to the specified address.
     * @param to The address that will receive the soulbound token.
     * @return tokenId The ID of the newly minted token.
     * @notice Only the contract owner can call this function.
     * Once minted, the token cannot be transferred.
     */
    function mint(address to) public onlyOwner returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        
        emit SoulboundTokenMinted(to, tokenId);
        return tokenId;
    }

    /**
     * @dev Batch mints multiple soulbound tokens.
     * @param recipients Array of addresses that will receive tokens.
     * @notice Only the contract owner can call this function.
     */
    function batchMint(address[] calldata recipients) public onlyOwner {
        require(recipients.length > 0, "Empty recipients array");
        require(recipients.length <= 100, "Too many recipients");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot mint to zero address");
            uint256 tokenId = _nextTokenId++;
            _safeMint(recipients[i], tokenId);
            emit SoulboundTokenMinted(recipients[i], tokenId);
        }
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
     * @dev Override _update to prevent transfers (making tokens soulbound).
     * @notice This function blocks all transfers except minting and burning.
     * Minting (from == address(0)) and burning (to == address(0)) are allowed.
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == address(0))
        // Allow burning (to == address(0))
        // Block all other transfers
        require(
            from == address(0) || to == address(0),
            "Soulbound: Token cannot be transferred"
        );
        
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Override to prevent approvals (since transfers are blocked).
     */
    function approve(address /* to */, uint256 /* tokenId */) public virtual override {
        revert("Soulbound: Token cannot be approved for transfer");
    }

    /**
     * @dev Override to prevent approvals for all (since transfers are blocked).
     */
    function setApprovalForAll(address /* operator */, bool /* approved */) public virtual override {
        revert("Soulbound: Token cannot be approved for transfer");
    }
}
