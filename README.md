# Nockchain

**Nockchain is a lightweight blockchain for heavyweight verifiable applications.**


We believe the future of blockchains is lightweight trustless settlement of heavyweight verifiable computation. The only way to get there is by replacing verifiability-via-public-replication with verifiability-via-private-proving. Proving happens off-chain; verification is on-chain.


## Setup

Install `rustup` by following their instructions at: [https://rustup.rs/](https://rustup.rs/)

If using Windows Subsystem for Linux (WSL):

```
export CARGO_TARGET_DIR=<location of nockchain>/target
sudo apt install -y clang libclang-dev
```

Install `choo`, the Hoon compiler:

```
make install-choo
```

## Build

To build Nockchain:

```
make build-hoon-all
make build
```

To run a Nockchain node that publishes the genesis block:

```
make run-nockchain-leader
```


To run a Nockchain node that waits for the genesis block:

```
make run-nockchain-follower
```


To run the test suite:

```
make test
```



