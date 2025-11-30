// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title UniswapRouterMock
 * @dev Mock DEX router for testing purposes.
 * @notice Simulates Uniswap-like token swaps for local development/testing.
 * NOT FOR PRODUCTION USE.
 */
contract UniswapRouterMock {
    /// @dev Simulated exchange rate (1:1 for simplicity)
    uint256 public constant MOCK_RATE = 1;

    /**
     * @dev Emitted when a token swap is simulated.
     */
    event SwapExecuted(
        address indexed caller,
        uint256 amountIn,
        uint256 amountOut,
        address[] path,
        address indexed to
    );

    /**
     * @dev Mock implementation of swapExactTokensForTokens.
     * @param amountIn The amount of input tokens to swap.
     * @param amountOutMin The minimum amount of output tokens expected.
     * @param path Array of token addresses representing the swap path.
     * @param to Address to receive the output tokens.
     * @param deadline Timestamp by which the transaction must be executed.
     * @return amounts Array containing input and output amounts.
     * @notice This is a simplified mock. Assumes 1:1 exchange rate.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        require(amountIn > 0, "Amount in must be greater than 0");
        require(path.length >= 2, "Invalid path");
        require(to != address(0), "Invalid recipient");
        require(deadline >= block.timestamp, "Transaction expired");

        address tokenIn = path[0];
        address tokenOut = path[path.length - 1];

        // Calculate mock output amount (1:1 ratio for simplicity)
        uint256 amountOut = amountIn * MOCK_RATE;
        require(amountOut >= amountOutMin, "Insufficient output amount");

        // Transfer input tokens from caller to this contract
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "Transfer of input tokens failed"
        );

        // Transfer output tokens from this contract to recipient
        require(
            IERC20(tokenOut).transfer(to, amountOut),
            "Transfer of output tokens failed"
        );

        // Prepare return array
        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;

        emit SwapExecuted(msg.sender, amountIn, amountOut, path, to);

        return amounts;
    }

    /**
     * @dev Mock implementation of getAmountsOut.
     * @param amountIn The amount of input tokens.
     * @param path Array of token addresses representing the swap path.
     * @return amounts Array of amounts for each token in the path.
     * @notice Returns a 1:1 ratio for testing purposes.
     */
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        pure
        returns (uint256[] memory amounts)
    {
        require(amountIn > 0, "Amount in must be greater than 0");
        require(path.length >= 2, "Invalid path");

        amounts = new uint256[](path.length);
        amounts[0] = amountIn;

        // Mock 1:1 conversion for all hops
        for (uint256 i = 1; i < path.length; i++) {
            amounts[i] = amounts[i - 1] * MOCK_RATE;
        }

        return amounts;
    }

    /**
     * @dev Allows contract owner to fund the mock router with tokens for testing.
     * @param token The token address to deposit.
     * @param amount The amount of tokens to deposit.
     * @notice Anyone can fund this mock router for testing.
     */
    function fundRouter(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");

        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    /**
     * @dev Returns the balance of a specific token held by this contract.
     * @param token The token address to query.
     * @return The token balance.
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @dev Emergency function to withdraw tokens from the mock router.
     * @param token The token address to withdraw.
     * @param amount The amount to withdraw.
     * @param to The recipient address.
     * @notice For testing purposes only.
     */
    function emergencyWithdraw(
        address token,
        uint256 amount,
        address to
    ) external {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");

        require(IERC20(token).transfer(to, amount), "Transfer failed");
    }
}
