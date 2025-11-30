// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TimeLockVault
 * @dev Vault contract that locks Ether until a specific unlock time.
 * @notice Only the owner can withdraw after the unlock time has passed.
 */
contract TimeLockVault is Ownable {
    /// @dev Timestamp when the vault can be unlocked
    uint256 public unlockTime;

    /// @dev Total amount deposited in the vault
    uint256 public totalDeposited;

    /**
     * @dev Emitted when Ether is deposited into the vault.
     */
    event Deposited(address indexed depositor, uint256 amount, uint256 unlockTime);

    /**
     * @dev Emitted when Ether is withdrawn from the vault.
     */
    event Withdrawn(address indexed owner, uint256 amount);

    /**
     * @dev Emitted when the unlock time is extended.
     */
    event UnlockTimeExtended(uint256 oldUnlockTime, uint256 newUnlockTime);

    /**
     * @dev Constructor sets the unlock time.
     * @param _unlockTime Unix timestamp when funds can be withdrawn.
     * @notice Unlock time must be in the future.
     */
    constructor(uint256 _unlockTime) Ownable(msg.sender) {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        unlockTime = _unlockTime;
    }

    /**
     * @dev Allows anyone to deposit Ether into the vault.
     * @notice Funds will be locked until unlock time.
     */
    function deposit() external payable {
        require(msg.value > 0, "Must deposit some Ether");
        totalDeposited += msg.value;
        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    /**
     * @dev Allows the owner to withdraw all funds after unlock time.
     * @notice Can only be called by owner and only after unlock time.
     */
    function withdraw() external onlyOwner {
        require(block.timestamp >= unlockTime, "Vault is still locked");
        require(address(this).balance > 0, "No funds to withdraw");

        uint256 amount = address(this).balance;
        totalDeposited = 0;

        (bool success, ) = owner().call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(owner(), amount);
    }

    /**
     * @dev Allows the owner to withdraw a specific amount after unlock time.
     * @param amount The amount of Ether to withdraw in wei.
     * @notice Can only be called by owner and only after unlock time.
     */
    function withdrawAmount(uint256 amount) external onlyOwner {
        require(block.timestamp >= unlockTime, "Vault is still locked");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient balance");

        totalDeposited -= amount;

        (bool success, ) = owner().call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(owner(), amount);
    }

    /**
     * @dev Extends the unlock time to a later date.
     * @param newUnlockTime The new unlock timestamp.
     * @notice Only owner can extend. New time must be later than current unlock time.
     */
    function extendUnlockTime(uint256 newUnlockTime) external onlyOwner {
        require(newUnlockTime > unlockTime, "New unlock time must be later");
        require(newUnlockTime > block.timestamp, "New unlock time must be in future");

        uint256 oldUnlockTime = unlockTime;
        unlockTime = newUnlockTime;

        emit UnlockTimeExtended(oldUnlockTime, newUnlockTime);
    }

    /**
     * @dev Returns the current vault balance.
     * @return The balance in wei.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the time remaining until unlock.
     * @return The number of seconds until unlock (0 if already unlocked).
     */
    function getTimeUntilUnlock() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }

    /**
     * @dev Checks if the vault is currently unlocked.
     * @return True if current time >= unlock time.
     */
    function isUnlocked() external view returns (bool) {
        return block.timestamp >= unlockTime;
    }

    /**
     * @dev Fallback function to accept Ether deposits.
     */
    receive() external payable {
        totalDeposited += msg.value;
        emit Deposited(msg.sender, msg.value, unlockTime);
    }
}
