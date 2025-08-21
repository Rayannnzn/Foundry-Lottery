# 🎟️ Raffle Lottery (Chainlink VRF + Automation)

A decentralized **lottery / raffle contract** built with Solidity and [Chainlink VRF v2.5](https://docs.chain.link/vrf/v2/introduction) for provably fair randomness.  
The contract automatically picks a winner at time intervals using **Chainlink Automation (Keepers)**.  

---

## 📌 Features
- 🎲 **Provably Fair Randomness** with Chainlink VRF v2.5  
- ⏱️ **Automated Winner Selection** using Chainlink Automation  
- 💰 Players enter by paying an entrance fee in ETH  
- 🏆 Winner is chosen at random and receives the pot  
- ✅ Uses **CEI Pattern** (Checks → Effects → Interactions) for safety  
- 🛡️ Custom Errors for gas optimization  

---

## 🛠️ Tech Stack
- Solidity `^0.8.19`
- [Foundry](https://book.getfoundry.sh/) (Forge & Cast)
- [Chainlink VRF v2.5](https://docs.chain.link/vrf/v2/introduction)
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts) (for patterns & utils)

---

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
