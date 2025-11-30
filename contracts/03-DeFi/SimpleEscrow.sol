// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleEscrow
 * @dev Ethereum-based escrow contract holding funds between two parties with arbiter control.
 * @notice The arbiter has exclusive rights to release funds to beneficiary or refund to initiator.
 */
contract SimpleEscrow {
    /// @dev Address that initiated the escrow and deposited funds
    address payable public initiator;

    /// @dev Address that will receive funds upon release
    address payable public beneficiary;

    /// @dev Address with authority to release or refund
    address public arbiter;

    /// @dev Amount of Ether held in escrow
    uint256 public amount;

    /// @dev Whether the escrow has been completed (released or refunded)
    bool public isCompleted;

    /**
     * @dev Emitted when funds are deposited into escrow.
     */
    event Deposited(address indexed initiator, uint256 amount);

    /**
     * @dev Emitted when funds are released to beneficiary.
     */
    event Released(address indexed beneficiary, uint256 amount);

    /**
     * @dev Emitted when funds are refunded to initiator.
     */
    event Refunded(address indexed initiator, uint256 amount);

    /**
     * @dev Constructor sets up the escrow parties.
     * @param _beneficiary Address that will receive funds upon release.
     * @param _arbiter Address with authority to release or refund.
     */
    constructor(address payable _beneficiary, address _arbiter) payable {
        require(_beneficiary != address(0), "Beneficiary cannot be zero address");
        require(_arbiter != address(0), "Arbiter cannot be zero address");
        require(msg.value > 0, "Must deposit funds");

        initiator = payable(msg.sender);
        beneficiary = _beneficiary;
        arbiter = _arbiter;
        amount = msg.value;
        isCompleted = false;

        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Modifier to ensure only arbiter can call function.
     */
    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call this");
        _;
    }

    /**
     * @dev Modifier to ensure escrow is not already completed.
     */
    modifier notCompleted() {
        require(!isCompleted, "Escrow already completed");
        _;
    }

    /**
     * @dev Releases escrowed funds to the beneficiary.
     * @notice Only the arbiter can call this function.
     */
    function release() external onlyArbiter notCompleted {
        isCompleted = true;
        uint256 amountToSend = amount;
        amount = 0;

        (bool success, ) = beneficiary.call{value: amountToSend}("");
        require(success, "Transfer to beneficiary failed");

        emit Released(beneficiary, amountToSend);
    }

    /**
     * @dev Refunds escrowed funds to the initiator.
     * @notice Only the arbiter can call this function.
     */
    function refund() external onlyArbiter notCompleted {
        isCompleted = true;
        uint256 amountToSend = amount;
        amount = 0;

        (bool success, ) = initiator.call{value: amountToSend}("");
        require(success, "Transfer to initiator failed");

        emit Refunded(initiator, amountToSend);
    }

    /**
     * @dev Returns the current contract balance.
     * @return The balance in wei.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
