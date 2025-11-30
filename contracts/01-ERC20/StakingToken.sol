// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title StakingToken
 * @dev ERC-20 token with role-based access control for minting staking rewards.
 * @notice This token uses OpenZeppelin's AccessControl to manage minting permissions.
 * The deployer is granted both MINTER_ROLE and DEFAULT_ADMIN_ROLE.
 */
contract StakingToken is ERC20, AccessControl {
    /// @dev Role identifier for accounts authorized to mint tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @dev Constructor that sets up initial roles and mints initial supply.
     * @param initialSupply The initial number of tokens to mint to the deployer.
     * @notice Deployer receives MINTER_ROLE and DEFAULT_ADMIN_ROLE.
     */
    constructor(uint256 initialSupply) ERC20("StakingToken", "STAKE") {
        // Grant the deployer the default admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        
        // Grant the deployer the minter role
        _grantRole(MINTER_ROLE, msg.sender);
        
        // Mint initial supply to deployer
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mints staking rewards to a specified address.
     * @param to The address that will receive the minted tokens.
     * @param amount The number of tokens to mint as rewards.
     * @notice Only accounts with MINTER_ROLE can call this function.
     */
    function mintRewards(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Batch mints staking rewards to multiple addresses.
     * @param recipients Array of addresses that will receive tokens.
     * @param amounts Array of token amounts corresponding to each recipient.
     * @notice Only accounts with MINTER_ROLE can call this function.
     * Arrays must have the same length.
     */
    function batchMintRewards(address[] calldata recipients, uint256[] calldata amounts) 
        public 
        onlyRole(MINTER_ROLE) 
    {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        require(recipients.length > 0, "Empty arrays");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
        }
    }
}
