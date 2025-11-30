// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CappedToken
 * @dev ERC-20 token with a supply cap of 1,000,000 tokens.
 * @notice This token enforces a maximum supply limit. No additional tokens
 * can be minted once the cap is reached, ensuring scarcity.
 */
contract CappedToken is ERC20, ERC20Capped, Ownable {
    /**
     * @dev Constructor that sets the supply cap and mints the initial supply.
     * @param initialSupply The initial number of tokens to mint (must not exceed cap).
     * @notice The cap is set to 1,000,000 tokens (with 18 decimals).
     */
    constructor(uint256 initialSupply) 
        ERC20("CappedToken", "CAP") 
        ERC20Capped(1_000_000 * 10**18) 
        Ownable(msg.sender) 
    {
        require(initialSupply <= 1_000_000 * 10**18, "Initial supply exceeds cap");
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mints new tokens to a specified address.
     * @param to The address that will receive the minted tokens.
     * @param amount The number of tokens to mint.
     * @notice Only the owner can mint tokens, and total supply cannot exceed the cap.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Internal function to handle minting with cap enforcement.
     * @notice Overrides both ERC20 and ERC20Capped to enforce the supply cap.
     */
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }
}
