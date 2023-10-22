# Contract Module for Blockcraft ETH Online 2023

## Verification
### Scroll-Sepolia
- WorldNFT [link](https://sepolia.scrollscan.dev/address/0x304Ad60027Bc6A8128E4AE1dE862E86B6cc37154#code)
- ItemFactory [link](https://sepolia.scrollscan.dev/address/0x0C769dd6d69DabD6a4151B579A42E49A54074d62#code)
### Scroll Cross Chain Deployments
- **Ethereum Sepolia**
    - ItemFactory-Operator [link](https://sepolia.etherscan.io/address/0x62A9AA8Eae2BCEBc42b93b73e977AC748EA81e66#code)
    - WorldNFT-Operator [link](https://sepolia.etherscan.io/address/0x4302bFe57631edF12F1969f773B1F0e68348bAc5#code)

## contracts 
 - Core contracts are in [contracts](contracts)
 - Scroll Cross chain module operator [constracts/Scroll-CrossChain](constracts/Scroll-CrossChain)

## Deployments
- [Scripts](scripts)

## Tests
- [Tests](test)

## Helper Scripts
- [helper](helper)

### Backend repo [link](https://github.com/startup-dreamer/backend), Frontend repo [link](https://github.com/startup-dreamer/Blockcraft-Frontend)

## Hardhat Commands
```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

## Foundry Commands
```shell
forge install
forge compile
forge test
```