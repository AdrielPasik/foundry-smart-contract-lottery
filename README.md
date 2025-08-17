# Decentralized Smart Contract Lottery

A provably fair, verifiably random lottery smart contract built with Solidity and Foundry. This project is part of the Cyfrin Updrafts "Foundry Fundamentals" course.

## Overview

This decentralized lottery system allows users to:

- Enter the lottery by paying an entrance fee
- Automatically select a winner after a specified time interval
- Transfer the entire prize pool to the winner
- Use Chainlink VRF (Verifiable Random Function) for guaranteed randomness

## Technologies Used

- **Solidity** - Smart contract development
- **Foundry** - Development framework
- **Chainlink VRF** - Verifiable randomness
- **Chainlink Automation** - Decentralized execution

## Features

- ✅ Fully automated drawing system
- ✅ Transparent selection process
- ✅ Verifiably random winner selection
- ✅ Customizable entrance fee and time interval
- ✅ Gas-optimized contract design

## Project Structure

- `src/`: Smart contract source code
- `test/unit/`: Unit tests
- `test/integration/`: Integration tests
- `script/`: Deployment and interaction scripts

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/foundry-smart-contract-lottery.git
cd foundry-smart-contract-lottery
```
2. Install dependencies:
   forge install

3. Build the project:
   forge install

Testing

Run all tests: forge test
Run specific tests: forge test --match-test testEnteringRaffleEmitsEvent
Run with gas report: forge test --gas-report

Deployment

Set up your environment variables:
# .env file
SEPOLIA_RPC_URL=your_rpc_url
PRIVATE_KEY=your_private_key

Deploy to Sepolia testnet:
forge script script/DeployRaffle.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY

For local deployment:
anvil
# In another terminal
forge script script/DeployRaffle.s.sol --rpc-url http://localhost:8545 --broadcast

Contract Details
The Raffle contract implements:

Entrance fee collection
Random winner selection via Chainlink VRF
Automatic state management
Time-based lottery interval
Prize distribution to winner

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

Acknowledgments
Cyfrin Updrafts for their excellent "Foundry Fundamentals" course
Chainlink for providing decentralized oracle services
