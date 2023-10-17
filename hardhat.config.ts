import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from .env file

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  solidity: {
    version: '0.8.0', // Replace with the desired Solidity version
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    gasPrice: 0,
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.infura.io/v3/${
          process.env.API_KEY ? process.env.API_KEY : ''
        }`,
        blockNumber: 14390000,
      },
      accounts: {
        count: 50,
      },
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${
        process.env.API_KEY ? process.env.API_KEY : ''
      }`, // Replace with the actual URL of the sepoli network
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${
        process.env.API_KEY ? process.env.API_KEY : ''
      }`, // Replace with the actual URL of the goerli network
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    mumbai: {
      url: 'https://rpc.ankr.com/polygon_mumbai',
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    polygon: {
      url: 'https://rpc-mainnet.maticvigil.com',
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY
        ? process.env.ETHERSCAN_API_KEY
        : '',
      sepolia: process.env.ETHERSCAN_API_KEY
        ? process.env.ETHERSCAN_API_KEY
        : '',
      polygon: process.env.POLYGONSCAN_API_KEY
        ? process.env.POLYGONSCAN_API_KEY
        : '',
    },
  },

};

export default config;
