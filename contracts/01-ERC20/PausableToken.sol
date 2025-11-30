// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PausableToken
 * @dev ERC-20 token with pausable transfer functionality.
 * @notice This token allows the owner to pause and unpause all token transfers.
 * Useful for emergency situations or scheduled maintenance.
 */
contract PausableToken is ERC20, ERC20Pausable, Ownable {
    /**
     * @dev Constructor that mints the initial supply to the deployer.
     * @param initialSupply The total number of tokens to mint (in smallest units).
     */
    constructor(uint256 initialSupply) ERC20("PausableToken", "PAUSE") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Pauses all token transfers.
     * @notice Only the contract owner can call this function.
     * When paused, no transfers, mints, or burns can occur.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     * @notice Only the contract owner can call this function.
     * Restores normal token functionality.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Internal function to handle token transfers with pause check.
     * @notice Overrides both ERC20 and ERC20Pausable to enforce pause functionality.
     */
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
