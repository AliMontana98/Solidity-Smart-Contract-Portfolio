// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WhitelistNFT
 * @dev ERC-721 NFT with whitelist-based minting mechanism.
 * @notice Only whitelisted addresses can mint NFTs from this contract.
 */
contract WhitelistNFT is ERC721, Ownable {
    /// @dev Counter for tracking the next token ID to mint
    uint256 private _nextTokenId;

    /// @dev Maximum number of NFTs that can be minted per whitelisted address
    uint256 public maxMintsPerAddress;

    /// @dev Mapping to track whitelisted addresses
    mapping(address => bool) private _whitelist;

    /// @dev Mapping to track how many NFTs each address has minted
    mapping(address => uint256) private _mintedCount;

    /// @dev Whether public minting is currently enabled
    bool public mintingEnabled;

    /**
     * @dev Emitted when an address is added to the whitelist.
     */
    event AddedToWhitelist(address indexed account);

    /**
     * @dev Emitted when an address is removed from the whitelist.
     */
    event RemovedFromWhitelist(address indexed account);

    /**
     * @dev Constructor that sets the NFT name, symbol, and max mints per address.
     * @param _maxMintsPerAddress Maximum NFTs each whitelisted address can mint.
     */
    constructor(uint256 _maxMintsPerAddress) ERC721("WhitelistNFT", "WNFT") Ownable(msg.sender) {
        require(_maxMintsPerAddress > 0, "Max mints must be greater than 0");
        maxMintsPerAddress = _maxMintsPerAddress;
        mintingEnabled = false;
    }

    /**
     * @dev Adds an address to the whitelist.
     * @param account The address to whitelist.
     * @notice Only the contract owner can call this function.
     */
    function addToWhitelist(address account) public onlyOwner {
        require(!_whitelist[account], "Address already whitelisted");
        _whitelist[account] = true;
        emit AddedToWhitelist(account);
    }

    /**
     * @dev Adds multiple addresses to the whitelist in batch.
     * @param accounts Array of addresses to whitelist.
     * @notice Only the contract owner can call this function.
     */
    function batchAddToWhitelist(address[] calldata accounts) public onlyOwner {
        require(accounts.length > 0, "Empty array");
        require(accounts.length <= 200, "Too many addresses");
        
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_whitelist[accounts[i]]) {
                _whitelist[accounts[i]] = true;
                emit AddedToWhitelist(accounts[i]);
            }
        }
    }

    /**
     * @dev Removes an address from the whitelist.
     * @param account The address to remove.
     * @notice Only the contract owner can call this function.
     */
    function removeFromWhitelist(address account) public onlyOwner {
        require(_whitelist[account], "Address not whitelisted");
        _whitelist[account] = false;
        emit RemovedFromWhitelist(account);
    }

    /**
     * @dev Enables or disables public minting.
     * @param enabled Whether minting should be enabled.
     * @notice Only the contract owner can call this function.
     */
    function setMintingEnabled(bool enabled) public onlyOwner {
        mintingEnabled = enabled;
    }

    /**
     * @dev Updates the maximum mints per address.
     * @param _maxMintsPerAddress New maximum mints per address.
     * @notice Only the contract owner can call this function.
     */
    function setMaxMintsPerAddress(uint256 _maxMintsPerAddress) public onlyOwner {
        require(_maxMintsPerAddress > 0, "Max mints must be greater than 0");
        maxMintsPerAddress = _maxMintsPerAddress;
    }

    /**
     * @dev Public mint function for whitelisted addresses.
     * @return tokenId The ID of the newly minted token.
     * @notice Requires the caller to be whitelisted and minting to be enabled.
     */
    function mint() public returns (uint256) {
        require(mintingEnabled, "Minting is not enabled");
        require(_whitelist[msg.sender], "Address not whitelisted");
        require(_mintedCount[msg.sender] < maxMintsPerAddress, "Mint limit reached");

        uint256 tokenId = _nextTokenId++;
        _mintedCount[msg.sender]++;
        _safeMint(msg.sender, tokenId);
        
        return tokenId;
    }

    /**
     * @dev Checks if an address is whitelisted.
     * @param account The address to check.
     * @return Whether the address is whitelisted.
     */
    function isWhitelisted(address account) public view returns (bool) {
        return _whitelist[account];
    }

    /**
     * @dev Returns the number of NFTs minted by an address.
     * @param account The address to check.
     * @return The number of NFTs minted.
     */
    function mintedBy(address account) public view returns (uint256) {
        return _mintedCount[account];
    }

    /**
     * @dev Returns the total number of tokens minted.
     * @return The total supply of minted tokens.
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}
