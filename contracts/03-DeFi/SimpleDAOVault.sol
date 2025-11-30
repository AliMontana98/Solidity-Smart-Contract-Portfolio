// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SimpleDAOVault
 * @dev Governance-controlled vault for DAO treasury management.
 * @notice Only addresses with GOVERNANCE_ROLE can execute transactions.
 */
contract SimpleDAOVault is AccessControl {
    /// @dev Role identifier for governance members
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    /**
     * @dev Emitted when funds are deposited into the vault.
     */
    event Deposited(address indexed depositor, uint256 amount);

    /**
     * @dev Emitted when a transaction is executed by governance.
     */
    event Executed(
        address indexed executor,
        address indexed target,
        uint256 value,
        bytes data,
        bool success
    );

    /**
     * @dev Emitted when a new governance member is added.
     */
    event GovernanceMemberAdded(address indexed account);

    /**
     * @dev Emitted when a governance member is removed.
     */
    event GovernanceMemberRemoved(address indexed account);

    /**
     * @dev Constructor grants DEFAULT_ADMIN_ROLE and GOVERNANCE_ROLE to deployer.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GOVERNANCE_ROLE, msg.sender);
    }

    /**
     * @dev Allows anyone to deposit Ether into the vault.
     */
    function deposit() external payable {
        require(msg.value > 0, "Must deposit some Ether");
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Executes a transaction from the vault.
     * @param target The address to call.
     * @param value The amount of Ether to send.
     * @param data The calldata to send.
     * @return success Whether the call succeeded.
     * @notice Only governance role can call this function.
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external onlyRole(GOVERNANCE_ROLE) returns (bool success) {
        require(target != address(0), "Invalid target address");
        require(address(this).balance >= value, "Insufficient balance");

        (success, ) = target.call{value: value}(data);
        
        emit Executed(msg.sender, target, value, data, success);
        return success;
    }

    /**
     * @dev Batch executes multiple transactions.
     * @param targets Array of addresses to call.
     * @param values Array of Ether amounts to send.
     * @param datas Array of calldata to send.
     * @notice Only governance role can call this. Arrays must have same length.
     */
    function batchExecute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external onlyRole(GOVERNANCE_ROLE) {
        require(
            targets.length == values.length && values.length == datas.length,
            "Arrays length mismatch"
        );
        require(targets.length > 0, "Empty arrays");
        require(targets.length <= 10, "Too many transactions");

        for (uint256 i = 0; i < targets.length; i++) {
            require(targets[i] != address(0), "Invalid target address");
            require(address(this).balance >= values[i], "Insufficient balance");

            (bool success, ) = targets[i].call{value: values[i]}(datas[i]);
            emit Executed(msg.sender, targets[i], values[i], datas[i], success);
        }
    }

    /**
     * @dev Adds a new governance member.
     * @param account The address to grant governance role.
     * @notice Only admin can call this function.
     */
    function addGovernanceMember(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Invalid address");
        grantRole(GOVERNANCE_ROLE, account);
        emit GovernanceMemberAdded(account);
    }

    /**
     * @dev Removes a governance member.
     * @param account The address to revoke governance role.
     * @notice Only admin can call this function.
     */
    function removeGovernanceMember(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(GOVERNANCE_ROLE, account);
        emit GovernanceMemberRemoved(account);
    }

    /**
     * @dev Checks if an address has governance role.
     * @param account The address to check.
     * @return True if address has governance role.
     */
    function isGovernanceMember(address account) external view returns (bool) {
        return hasRole(GOVERNANCE_ROLE, account);
    }

    /**
     * @dev Returns the current vault balance.
     * @return The balance in wei.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Fallback function to accept Ether deposits.
     */
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }
}
