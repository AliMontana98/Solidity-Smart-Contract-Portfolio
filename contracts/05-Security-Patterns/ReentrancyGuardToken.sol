// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ReentrancyGuardToken
 * @dev Demonstrates reentrancy protection using OpenZeppelin's ReentrancyGuard.
 * @notice This contract protects withdrawal functions from reentrancy attacks.
 */
contract ReentrancyGuardToken is ReentrancyGuard, Ownable {
    /// @dev Mapping of user balances
    mapping(address => uint256) public balances;

    /// @dev Total deposits in the contract
    uint256 public totalDeposits;

    /**
     * @dev Emitted when a user deposits funds.
     */
    event Deposited(address indexed user, uint256 amount);

    /**
     * @dev Emitted when a user withdraws funds.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Emitted when owner withdraws fees.
     */
    event FeesWithdrawn(address indexed owner, uint256 amount);

    /**
     * @dev Constructor sets the contract owner.
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev Allows users to deposit Ether.
     */
    function deposit() external payable {
        require(msg.value > 0, "Must deposit some Ether");
        
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Allows users to withdraw their balance.
     * @param amount The amount to withdraw.
     * @notice Protected by ReentrancyGuard to prevent reentrancy attacks.
     */
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Update state BEFORE external call (Checks-Effects-Interactions)
        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        // External call after state update
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Allows users to withdraw their entire balance.
     * @notice Protected by ReentrancyGuard to prevent reentrancy attacks.
     */
    function withdrawAll() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // Update state BEFORE external call
        balances[msg.sender] = 0;
        totalDeposits -= amount;

        // External call after state update
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Batch withdraw for multiple users (owner only).
     * @param users Array of user addresses.
     * @param amounts Array of amounts to withdraw.
     * @notice Protected by ReentrancyGuard. Only owner can call.
     */
    function batchWithdraw(address[] calldata users, uint256[] calldata amounts)
        external
        onlyOwner
        nonReentrant
    {
        require(users.length == amounts.length, "Arrays length mismatch");
        require(users.length > 0 && users.length <= 50, "Invalid array length");

        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = amounts[i];

            require(balances[user] >= amount, "Insufficient user balance");

            // Update state
            balances[user] -= amount;
            totalDeposits -= amount;

            // External call
            (bool success, ) = user.call{value: amount}("");
            require(success, "Transfer failed");

            emit Withdrawn(user, amount);
        }
    }

    /**
     * @dev Returns the balance of a user.
     * @param user The address to query.
     * @return The user's balance.
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    /**
     * @dev Returns the contract's total Ether balance.
     * @return The contract balance.
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Fallback function to accept Ether.
     */
    receive() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}
