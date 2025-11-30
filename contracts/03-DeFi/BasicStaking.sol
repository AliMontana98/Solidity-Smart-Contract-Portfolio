// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BasicStaking
 * @dev Simple staking contract for ERC20 tokens with stake tracking.
 * @notice Users can stake and unstake tokens. Focuses on state management.
 */
contract BasicStaking is Ownable {
    /// @dev The ERC20 token used for staking
    IERC20 public stakingToken;

    /// @dev Total amount of tokens staked in the contract
    uint256 public totalStaked;

    /// @dev Mapping of user addresses to their staked amounts
    mapping(address => uint256) public stakedBalance;

    /// @dev Mapping of user addresses to their stake timestamp
    mapping(address => uint256) public stakeTimestamp;

    /**
     * @dev Emitted when a user stakes tokens.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @dev Emitted when a user unstakes tokens.
     */
    event Unstaked(address indexed user, uint256 amount);

    /**
     * @dev Emitted when owner withdraws emergency tokens.
     */
    event EmergencyWithdraw(address indexed owner, uint256 amount);

    /**
     * @dev Constructor sets the staking token.
     * @param _stakingToken Address of the ERC20 token to be staked.
     */
    constructor(address _stakingToken) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Invalid token address");
        stakingToken = IERC20(_stakingToken);
    }

    /**
     * @dev Allows users to stake tokens.
     * @param amount The amount of tokens to stake.
     * @notice User must approve this contract to spend tokens first.
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0 tokens");

        // Transfer tokens from user to contract
        require(
            stakingToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Update state
        stakedBalance[msg.sender] += amount;
        stakeTimestamp[msg.sender] = block.timestamp;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Allows users to unstake their tokens.
     * @param amount The amount of tokens to unstake.
     */
    function unstake(uint256 amount) external {
        require(amount > 0, "Cannot unstake 0 tokens");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");

        // Update state
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        // Transfer tokens back to user
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Returns the staked balance of a user.
     * @param user The address to query.
     * @return The amount of tokens staked by the user.
     */
    function getStakedBalance(address user) external view returns (uint256) {
        return stakedBalance[user];
    }

    /**
     * @dev Returns how long a user has been staking (in seconds).
     * @param user The address to query.
     * @return The number of seconds since the user staked.
     */
    function getStakeDuration(address user) external view returns (uint256) {
        if (stakeTimestamp[user] == 0) {
            return 0;
        }
        return block.timestamp - stakeTimestamp[user];
    }

    /**
     * @dev Emergency function to withdraw tokens from contract.
     * @param amount The amount of tokens to withdraw.
     * @notice Only owner can call this. Use in case of emergency.
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot withdraw 0 tokens");
        require(
            stakingToken.balanceOf(address(this)) >= amount,
            "Insufficient contract balance"
        );

        require(stakingToken.transfer(owner(), amount), "Transfer failed");

        emit EmergencyWithdraw(owner(), amount);
    }

    /**
     * @dev Returns the total contract balance of staking tokens.
     * @return The total amount of tokens held by the contract.
     */
    function getContractBalance() external view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }
}
