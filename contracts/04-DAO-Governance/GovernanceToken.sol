// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GovernanceToken
 * @dev Standard ERC20 token with Permit for gasless approvals.
 * @notice Simplified governance token without on-chain voting checkpoints.
 */
contract GovernanceToken is ERC20, ERC20Permit, Ownable {
    constructor(uint256 initialSupply)
        ERC20("GovernanceToken", "GOV")
        ERC20Permit("GovernanceToken")
        Ownable(msg.sender)
    {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
