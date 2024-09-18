# Foundry Fork Testing Cheatcodes

## Introduction

Testing is important in smart contract development due to the immutable nature of smart contracts. Testing helps identify and resolve potential security vulnerabilities in smart contracts. Safeguard against unauthorized access.

Sometimes smart contract developers must interact with real-world data that testnet cannot provide. Hence, there is a need for fork testing. 

## Getting Started

1. Fork the repositry.
2. Cd into the project directory.
3. Create a `.env` file and add your MAINNET RPC URL.
4. Run the tests with the command:

   ```bash
    forge test
    ```

5. For trace result, run the command:

```bash
forge test -vvv
```

Or

```bash
forge test -vvvv
```