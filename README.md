# Contract Module for Blockcraft ETH Online 2023

## Verification
### Scroll-Sepolia
- WorldNFT [link]()
- ItemFactory [link]()
### Cross Chain Deployments
- **Polygon Mumbai**
    - ItemFactory-Operator [link]()
    - WorldNFT-Operator [link]()
- **Optimism Goerli**
    - ItemFactory-Operator [link]()
    - WorldNFT-Operator [link]()
- **Ethereum Sepolia**
    - ItemFactory-Operator [link]()
    - WorldNFT-Operator [link]()

## contracts 
 - Core contracts are in [contracts]('./contracts)
 - Scroll Cross chain module operator [constracts/Scroll-CrossChain]('./constracts/Scroll-CrossChain')

## Deployments
- [Scripts]('./scripts)

## Tests
- [Tests]('./test')

## Helper Scripts
- [helper]('./helper')


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