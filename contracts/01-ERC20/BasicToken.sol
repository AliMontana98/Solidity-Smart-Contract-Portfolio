// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title BasicToken
 * @dev A standard ERC-20 token with a fixed initial supply.
 * @notice This contract implements a basic fungible token with no additional features.
 * The total supply is minted to the deployer's address upon contract creation.
 */
contract BasicToken is ERC20 {
    /**
     * @dev Constructor that mints the initial supply to the deployer.
     * @param initialSupply The total number of tokens to mint (in smallest units).
     */
    constructor(uint256 initialSupply) ERC20("BasicToken", "BTK") {
        _mint(msg.sender, initialSupply);
    }
}
