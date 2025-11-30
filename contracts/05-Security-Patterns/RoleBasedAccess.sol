// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title RoleBasedAccess
 * @dev Complex example demonstrating granular access control with multiple roles.
 * @notice Uses OpenZeppelin AccessControl with MINTER, PAUSER, and UPGRADER roles.
 */
contract RoleBasedAccess is ERC20, AccessControl {
    /// @dev Role for minting new tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @dev Role for pausing the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @dev Role for upgrading contract parameters
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @dev Whether the contract is paused
    bool public paused;

    /// @dev Maximum supply cap (can be updated by UPGRADER_ROLE)
    uint256 public maxSupply;

    /// @dev Mapping to track blacklisted addresses
    mapping(address => bool) public blacklisted;

    /**
     * @dev Emitted when the contract is paused.
     */
    event Paused(address indexed pauser);

    /**
     * @dev Emitted when the contract is unpaused.
     */
    event Unpaused(address indexed pauser);

    /**
     * @dev Emitted when max supply is updated.
     */
    event MaxSupplyUpdated(uint256 oldSupply, uint256 newSupply);

    /**
     * @dev Emitted when an address is blacklisted.
     */
    event Blacklisted(address indexed account);

    /**
     * @dev Emitted when an address is removed from blacklist.
     */
    event RemovedFromBlacklist(address indexed account);

    /**
     * @dev Modifier to check if contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /**
     * @dev Constructor grants roles and sets initial parameters.
     * @param initialSupply Initial token supply to mint.
     * @param _maxSupply Maximum supply cap.
     */
    constructor(uint256 initialSupply, uint256 _maxSupply)
        ERC20("RoleBasedToken", "RBT")
    {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        require(initialSupply <= _maxSupply, "Initial supply exceeds max");

        maxSupply = _maxSupply;

        // Grant roles to deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        // Mint initial supply
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mints new tokens to a specified address.
     * @param to The address to receive tokens.
     * @param amount The amount of tokens to mint.
     * @notice Only MINTER_ROLE can call this.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(!blacklisted[to], "Recipient is blacklisted");
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");

        _mint(to, amount);
    }

    /**
     * @dev Burns tokens from caller's balance.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) public whenNotPaused {
        require(!blacklisted[msg.sender], "Sender is blacklisted");
        _burn(msg.sender, amount);
    }

    /**
     * @dev Pauses the contract.
     * @notice Only PAUSER_ROLE can call this.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        require(!paused, "Already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Unpauses the contract.
     * @notice Only PAUSER_ROLE can call this.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        require(paused, "Not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Updates the maximum supply.
     * @param newMaxSupply The new maximum supply.
     * @notice Only UPGRADER_ROLE can call this.
     */
    function updateMaxSupply(uint256 newMaxSupply) public onlyRole(UPGRADER_ROLE) {
        require(newMaxSupply >= totalSupply(), "New max supply below current supply");
        uint256 oldSupply = maxSupply;
        maxSupply = newMaxSupply;
        emit MaxSupplyUpdated(oldSupply, newMaxSupply);
    }

    /**
     * @dev Adds an address to the blacklist.
     * @param account The address to blacklist.
     * @notice Only DEFAULT_ADMIN_ROLE can call this.
     */
    function addToBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot blacklist zero address");
        require(!blacklisted[account], "Already blacklisted");
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Removes an address from the blacklist.
     * @param account The address to remove from blacklist.
     * @notice Only DEFAULT_ADMIN_ROLE can call this.
     */
    function removeFromBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(blacklisted[account], "Not blacklisted");
        blacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    /**
     * @dev Override transfer to check pause and blacklist status.
     */
    function _update(address from, address to, uint256 value) internal virtual override whenNotPaused {
        require(!blacklisted[from], "Sender is blacklisted");
        require(!blacklisted[to], "Recipient is blacklisted");
        super._update(from, to, value);
    }

    /**
     * @dev Returns whether an account has a specific role.
     * @param role The role identifier.
     * @param account The account to check.
     * @return True if account has the role.
     */
    function checkRole(bytes32 role, address account) public view returns (bool) {
        return hasRole(role, account);
    }
}
