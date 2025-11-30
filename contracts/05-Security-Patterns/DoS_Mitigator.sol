// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DoS_Mitigator
 * @dev Demonstrates how to avoid unbounded loops and DoS attacks.
 * @notice Uses pagination and limits to prevent gas exhaustion.
 */
contract DoS_Mitigator is Ownable {
    /// @dev Maximum batch size for operations
    uint256 public constant MAX_BATCH_SIZE = 50;

    /// @dev Array of registered users
    address[] public users;

    /// @dev Mapping to check if address is registered
    mapping(address => bool) public isRegistered;

    /// @dev Mapping of user to their balance
    mapping(address => uint256) public balances;

    /**
     * @dev Emitted when a user is registered.
     */
    event UserRegistered(address indexed user);

    /**
     * @dev Emitted when a user is removed.
     */
    event UserRemoved(address indexed user);

    /**
     * @dev Emitted when balance is updated.
     */
    event BalanceUpdated(address indexed user, uint256 newBalance);

    /**
     * @dev Constructor sets the contract owner.
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev Registers a new user.
     * @param user The address to register.
     * @notice Prevents unbounded array growth by limiting registrations.
     */
    function registerUser(address user) public onlyOwner {
        require(user != address(0), "Invalid address");
        require(!isRegistered[user], "User already registered");
        require(users.length < 10000, "Maximum users reached"); // DoS mitigation

        users.push(user);
        isRegistered[user] = true;

        emit UserRegistered(user);
    }

    /**
     * @dev Batch registers users with size limit.
     * @param newUsers Array of users to register.
     * @notice Limited to MAX_BATCH_SIZE to prevent DoS.
     */
    function batchRegisterUsers(address[] calldata newUsers) public onlyOwner {
        require(newUsers.length > 0, "Empty array");
        require(newUsers.length <= MAX_BATCH_SIZE, "Batch size exceeds limit");
        require(users.length + newUsers.length <= 10000, "Would exceed maximum users");

        for (uint256 i = 0; i < newUsers.length; i++) {
            address user = newUsers[i];
            require(user != address(0), "Invalid address");
            
            if (!isRegistered[user]) {
                users.push(user);
                isRegistered[user] = true;
                emit UserRegistered(user);
            }
        }
    }

    /**
     * @dev Updates balances in batches to avoid unbounded loops.
     * @param userAddresses Array of user addresses.
     * @param newBalances Array of new balances.
     * @notice Limited batch size prevents DoS attacks.
     */
    function batchUpdateBalances(
        address[] calldata userAddresses,
        uint256[] calldata newBalances
    ) public onlyOwner {
        require(userAddresses.length == newBalances.length, "Arrays length mismatch");
        require(userAddresses.length > 0, "Empty array");
        require(userAddresses.length <= MAX_BATCH_SIZE, "Batch size exceeds limit");

        for (uint256 i = 0; i < userAddresses.length; i++) {
            address user = userAddresses[i];
            require(isRegistered[user], "User not registered");

            balances[user] = newBalances[i];
            emit BalanceUpdated(user, newBalances[i]);
        }
    }

    /**
     * @dev Returns users in paginated form to avoid gas exhaustion.
     * @param offset Starting index.
     * @param limit Number of users to return.
     * @return paginatedUsers Array of user addresses.
     * @notice Pagination prevents reading entire array at once.
     */
    function getUsersPaginated(uint256 offset, uint256 limit)
        public
        view
        returns (address[] memory paginatedUsers)
    {
        require(limit > 0 && limit <= MAX_BATCH_SIZE, "Invalid limit");
        require(offset < users.length, "Offset out of bounds");

        uint256 end = offset + limit;
        if (end > users.length) {
            end = users.length;
        }

        uint256 resultLength = end - offset;
        paginatedUsers = new address[](resultLength);

        for (uint256 i = 0; i < resultLength; i++) {
            paginatedUsers[i] = users[offset + i];
        }

        return paginatedUsers;
    }

    /**
     * @dev Returns balances for a batch of users.
     * @param userAddresses Array of user addresses to query.
     * @return userBalances Array of balances.
     * @notice Limited batch size to prevent DoS.
     */
    function getBatchBalances(address[] calldata userAddresses)
        public
        view
        returns (uint256[] memory userBalances)
    {
        require(userAddresses.length > 0, "Empty array");
        require(userAddresses.length <= MAX_BATCH_SIZE, "Batch size exceeds limit");

        userBalances = new uint256[](userAddresses.length);

        for (uint256 i = 0; i < userAddresses.length; i++) {
            userBalances[i] = balances[userAddresses[i]];
        }

        return userBalances;
    }

    /**
     * @dev Returns the total number of registered users.
     * @return The total count.
     */
    function getUserCount() public view returns (uint256) {
        return users.length;
    }

    /**
     * @dev Removes a user by swapping with last element (gas efficient).
     * @param user The address to remove.
     * @notice Uses swap-and-pop pattern for efficient deletion.
     */
    function removeUser(address user) public onlyOwner {
        require(isRegistered[user], "User not registered");

        // Find user index
        uint256 index;
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == user) {
                index = i;
                break;
            }
        }

        // Swap with last element and pop (gas efficient)
        users[index] = users[users.length - 1];
        users.pop();

        isRegistered[user] = false;
        balances[user] = 0;

        emit UserRemoved(user);
    }
}
