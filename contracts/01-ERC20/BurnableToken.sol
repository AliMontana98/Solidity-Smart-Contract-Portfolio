// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BurnableToken
 * @dev ERC-20 token with burning capabilities controlled by the owner.
 * @notice This token allows the owner to burn tokens from any address,
 * reducing the total supply permanently.
 */
contract BurnableToken is ERC20, ERC20Burnable, Ownable {
    /**
     * @dev Constructor that mints the initial supply to the deployer.
     * @param initialSupply The total number of tokens to mint (in smallest units).
     */
    constructor(uint256 initialSupply) ERC20("BurnableToken", "BURN") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Burns tokens from a specified account.
     * @param account The address from which tokens will be burned.
     * @param amount The number of tokens to burn.
     * @notice Only the contract owner can call this function.
     */
    function burnFrom(address account, uint256 amount) public override onlyOwner {
        _burn(account, amount);
    }
}
