// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title EmergencyWithdraw
 * @dev Demonstrates the Circuit Breaker (Emergency Stop) pattern.
 * @notice Allows pausing the contract in emergencies and owner-only withdrawal.
 */
contract EmergencyWithdraw is Ownable, Pausable, ReentrancyGuard {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Deposit funds. Reverts if paused.
     */
    function deposit() external payable whenNotPaused {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw funds. Reverts if paused.
     */
    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    /**
     * @dev Emergency stop triggers pause.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Resume contract operation.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Emergency withdrawal by owner (only when paused).
     * @notice This is a critical security feature for fund recovery.
     */
    function emergencyWithdraw() external onlyOwner whenPaused {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}
