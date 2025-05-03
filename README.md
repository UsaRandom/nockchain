# Nockchain

**Nockchain is a lightweight blockchain for heavyweight verifiable applications.**

We believe the future of blockchains is lightweight trustless settlement of heavyweight verifiable computation. The only way to get there is by replacing verifiability-via-public-replication with verifiability-via-private-proving. Proving happens off-chain; verification is on-chain.

## Setup

### For Linux and macOS

1. Install `rustup` by following the instructions at: [https://rustup.rs/](https://rustup.rs/)
2. Install `choo`, the Hoon compiler:
   ```
   make install-choo
   ```

### For Windows (Using WSL)

To build and run Nockchain on Windows, you must use Windows Subsystem for Linux (WSL). Follow these steps:

1. **Install Windows Subsystem for Linux**
   - Open a Command Prompt and run:
     ```
     wsl.exe --install -d Debian
     ```
   - Restart your system after installation.
   - Open a WSL terminal by typing in Command Prompt:
     ```
     wsl.exe
     ```
   - Set a username and password when prompted in the WSL terminal.

2. **Install Required Packages**
   - In the WSL terminal, update the system and install necessary dependencies:
     ```
     sudo apt update -y && sudo apt upgrade -y
     sudo apt install -y curl
     sudo apt install -y make
     sudo apt install -y gcc
     sudo apt install -y clang libclang-dev
     sudo apt install -y git
     ```

3. **Install Rust**
   - Run the following command to install Rust:
     ```
     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
     ```
   - Close and reopen your WSL terminal after installing Rust.

4. **Download Nockchain Source**
   - Create a directory for Nockchain and clone the repository:
     ```
     mkdir /home/<username>/nockchain
     cd /home/<username>/nockchain
     git clone https://github.com/zorp-corp/nockchain.git .
     ```

5. **Install Choo**
   - In the Nockchain directory, run:
     ```
     make install-choo
     ```

## Build

To build Nockchain:

```
make build-hoon-all
make build
```

**Note for WSL Users**: The build process may appear to stall on `drivers::exit: exit_driver: waiting for effect` for a while. This is normal behavior.

## Run

To run a Nockchain node that publishes the genesis block:

```
make run-nockchain-leader
```

To run a Nockchain node that waits for the genesis block:

```
make run-nockchain-follower
```

## Test

To run the test suite:

```
make test
```
