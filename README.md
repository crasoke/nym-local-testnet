# Nym local testnet

This is a local testnet for the [Nym Network](https://github.com/nymtech/nym) in Docker. It creates a custom cosmos blockchain, uploads the nym smart contract, and then also launches the nym network with mixnodes, gateway, api, and clients. I took inspiration from the [docker](https://github.com/nymtech/nym/tree/develop/docker) folder in the nym repository.

Specifically, it will build and run the following containers:

* A genesis validator
* A secondary validator
* A contract builder that compiles the nym vesting and mixnet smart contracts
* A contract uploader that uploads and instantiates the smart contracts to the Cosmos blockchain.
* A binary builder that builds the nym binaries with modified smart contract addresses
* A nym API
* 3 mix nodes
* 1 entry gateway
* 2 nym clients

# Requirements

* Docker
* Docker compose

# Quickstart

To build and run the Docker environment, simply run
```bash
docker compose up
```
It will build and run all of the above containers. This may take a while.

If you want to rebuild the whole network and blockchain, delete the data folder + containers or use the script:
```bash
sh rebuild.sh
```