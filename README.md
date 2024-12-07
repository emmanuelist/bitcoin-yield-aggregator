# Bitcoin Yield Aggregator Smart Contract

## Overview

The Bitcoin Yield Aggregator is a Clarity smart contract designed to manage and aggregate Bitcoin yield across multiple protocols on the Stacks blockchain. This contract allows users to deposit Bitcoin, track yields from different protocols, and withdraw their funds with accrued returns.

## Features

- Multi-protocol yield aggregation
- Secure deposit and withdrawal mechanisms
- Dynamic protocol management
- Risk management through protocol deactivation
- Configurable yield calculations

## Prerequisites

- Stacks Blockchain
- Clarinet (for local development and testing)
- Basic understanding of Clarity smart contracts

## Installation

1. Clone the repository
2. Install Clarinet
3. Run `clarinet console` to interact with the contract

## Contract Capabilities

- Add and manage yield protocols
- Deposit funds into supported protocols
- Calculate yield based on protocol APY
- Withdraw funds and yields
- Deactivate protocols for risk management

## Security Measures

- Owner-only protocol management
- Input validation for all functions
- Maximum deposit and protocol limits
- Protocol activity tracking

## Supported Protocols

- Stacks Core Protocol
- Bitcoin Yield Plus

## Usage Example

```clarity
;; Deposit into a protocol
(contract-call? .bitcoin-yield deposit u1 u10000)

;; Calculate yield
(contract-call? .bitcoin-yield calculate-yield u1 tx-sender)

;; Withdraw funds
(contract-call? .bitcoin-yield withdraw u1 u5000)
```

## Risks and Considerations

- Yield calculations are simplified
- Actual returns may vary
- Smart contract interactions carry inherent blockchain risks

## Contributing

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Support

For support, please open an issue in the GitHub repository.
