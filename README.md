# 🏗️ Solidity Smart Contract Portfolio

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-363636?style=for-the-badge&logo=solidity)
![Security](https://img.shields.io/badge/Security-OpenZeppelin-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A curated collection of **24 production-ready smart contracts** demonstrating advanced patterns in DeFi, Governance, NFTs, and Security. This repository serves as a modular library of Web3 primitives designed for security, efficiency, and composability.

---

## 📂 Contract Library

The repository is organized into 5 specialized categories:

### 1. 🪙 ERC-20 Token Standards
*Foundational token models with varying mechanics.*
- **`BasicToken.sol`**: Standard fixed-supply implementation.
- **`BurnableToken.sol`**: Deflationary mechanics with owner-controlled burning.
- **`CappedToken.sol`**: Enforced supply caps for scarcity models.
- **`PausableToken.sol`**: Emergency circuit breakers for token transfers.
- **`StakingToken.sol`**: Access-controlled minting for reward distributions.

### 2. 🎨 NFT Mechanics (ERC-721)
*Advanced non-fungible token implementations.*
- **`SimpleNFT.sol`**: Optimized batch minting logic.
- **`RoyaltiesNFT.sol`**: EIP-2981 implementation for on-chain creator earnings.
- **`WhitelistNFT.sol`**: Merkle-proof/Mapping based allowlist architecture.
- **`SoulboundToken.sol`**: Non-transferable identity/reputation tokens.
- **`DynamicNFT.sol`**: Mutable metadata logic for evolving assets.

### 3. 💸 DeFi Primitives
*Core financial protocols and mechanisms.*
- **`SimpleEscrow.sol`**: Trust-minimized 3-party arbitration system.
- **`BasicStaking.sol`**: Time-weighted yield farming logic.
- **`TimeLockVault.sol`**: Secure asset vesting and delayed withdrawals.
- **`SimpleDAOVault.sol`**: Governance-controlled treasury management.
- **`UniswapRouterMock.sol`**: Simulation of DEX interactions for integration testing.

### 4. 🏛️ DAO & Governance
*On-chain decision making and execution systems.*
- **`GovernanceToken.sol`**: ERC20Permit integration for gasless voting.
- **`MultiSigWallet.sol`**: N-of-M consensus security for shared assets.
- **`CustomTimeLockController.sol`**: Enforced execution delays for admin actions.
- **`AccessControlledQueue.sol`**: Role-based proposal queuing and execution.

### 5. 🔒 Security Patterns
*Critical vulnerability mitigations and best practices.*
- **`ReentrancyGuardToken.sol`**: Checks-Effects-Interactions pattern implementation.
- **`RoleBasedAccess.sol`**: Granular permissioning (Minter, Pauser, Upgrader).
- **`PullPayment.sol`**: Withdrawal pattern to prevent DoS in fund distribution.
- **`DoS_Mitigator.sol`**: Gas limit protection via pagination and batching.
- **`EmergencyWithdraw.sol`**: Pausable circuit breakers for protocol safety.

---

## 🔐 Security & Standards

All contracts adhere to strict development standards:
- **Solidity ^0.8.20**: Utilizing the latest compiler features and overflow protection.
- **OpenZeppelin Integration**: Leveraging battle-tested libraries for core functionality.
- **NatSpec Documentation**: Full technical documentation for all functions and state variables.
- **Gas Optimization**: Efficient storage packing and logic execution.

---

## � Usage

These contracts are designed to be modular and can be imported directly into your project.

```solidity
// Example: Inheriting from the ReentrancyGuardToken
import "./contracts/05-Security-Patterns/ReentrancyGuardToken.sol";

contract MySecureProtocol is ReentrancyGuardToken {
    // Your custom logic here
}
```

---

## 📜 License

This project is licensed under the MIT License.
