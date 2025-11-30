// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PullPayment
 * @dev Implements the "pull over push" payment pattern for secure withdrawals.
 * @notice Users must manually withdraw their funds instead of automatic transfers.
 */
contract PullPayment is Ownable {
    /// @dev Mapping of user addresses to their pending payments
    mapping(address => uint256) public pendingPayments;

    /// @dev Total pending payments in the contract
    uint256 public totalPendingPayments;

    /**
     * @dev Emitted when a payment is credited to a user.
     */
    event PaymentCredited(address indexed recipient, uint256 amount);

    /**
     * @dev Emitted when a user withdraws their payment.
     */
    event PaymentWithdrawn(address indexed recipient, uint256 amount);

    /**
     * @dev Emitted when owner deposits funds.
     */
    event FundsDeposited(address indexed sender, uint256 amount);

    /**
     * @dev Constructor sets the contract owner.
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev Credits a payment to a user's account.
     * @param recipient The address to credit.
     * @param amount The amount to credit.
     * @notice Only owner can credit payments. Uses pull pattern.
     */
    function creditPayment(address recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= totalPendingPayments + amount, "Insufficient contract balance");

        pendingPayments[recipient] += amount;
        totalPendingPayments += amount;

        emit PaymentCredited(recipient, amount);
    }

    /**
     * @dev Batch credits payments to multiple users.
     * @param recipients Array of recipient addresses.
     * @param amounts Array of amounts to credit.
     * @notice Only owner can call. Arrays must have same length.
     */
    function batchCreditPayments(address[] calldata recipients, uint256[] calldata amounts)
        public
        onlyOwner
    {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        require(recipients.length > 0 && recipients.length <= 100, "Invalid array length");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(
            address(this).balance >= totalPendingPayments + totalAmount,
            "Insufficient contract balance"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            require(amounts[i] > 0, "Amount must be greater than 0");

            pendingPayments[recipients[i]] += amounts[i];
            totalPendingPayments += amounts[i];

            emit PaymentCredited(recipients[i], amounts[i]);
        }
    }

    /**
     * @dev Allows users to withdraw their pending payments.
     * @notice This is the "pull" mechanism - users initiate withdrawal.
     */
    function withdrawPayment() public {
        uint256 payment = pendingPayments[msg.sender];
        require(payment > 0, "No pending payment");

        // Update state BEFORE external call (Checks-Effects-Interactions)
        pendingPayments[msg.sender] = 0;
        totalPendingPayments -= payment;

        // External call after state update
        (bool success, ) = msg.sender.call{value: payment}("");
        require(success, "Transfer failed");

        emit PaymentWithdrawn(msg.sender, payment);
    }

    /**
     * @dev Allows users to withdraw a specific amount.
     * @param amount The amount to withdraw.
     */
    function withdrawPartialPayment(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(pendingPayments[msg.sender] >= amount, "Insufficient pending payment");

        // Update state BEFORE external call
        pendingPayments[msg.sender] -= amount;
        totalPendingPayments -= amount;

        // External call after state update
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit PaymentWithdrawn(msg.sender, amount);
    }

    /**
     * @dev Allows owner to deposit funds into the contract.
     */
    function depositFunds() public payable onlyOwner {
        require(msg.value > 0, "Must deposit some Ether");
        emit FundsDeposited(msg.sender, msg.value);
    }

    /**
     * @dev Returns the pending payment for a user.
     * @param user The address to query.
     * @return The pending payment amount.
     */
    function getPendingPayment(address user) public view returns (uint256) {
        return pendingPayments[user];
    }

    /**
     * @dev Returns the available funds (not pending payments).
     * @return The available balance.
     */
    function getAvailableFunds() public view returns (uint256) {
        return address(this).balance - totalPendingPayments;
    }

    /**
     * @dev Returns the contract's total balance.
     * @return The contract balance.
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Fallback function to accept Ether deposits.
     */
    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
}
