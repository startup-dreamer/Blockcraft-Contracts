import fs from "fs";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "@typechain/hardhat";
import "hardhat-preprocessor";
import dotenv from 'dotenv';


dotenv.config(); // Load environment variables from .env file

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  solidity: {
    version: '0.8.20', // Replace with the desired Solidity version
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.infura.io/v3/${process.env.API_KEY ? process.env.API_KEY : ''
          }`,
        blockNumber: 14390000,
      },
      accounts: {
        count: 50,
      },
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.SEPOLIA_API_KEY ? process.env.SEPOLIA_API_KEY : ''
        }`, // Replace with the actual URL of the sepoli network
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
    optimismGoerli: {
      url: `https://opt-goerli.g.alchemy.com/v2/${process.env.API_KEY ? process.env.API_KEY : ''}`,
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    scrollTestnet: {
      url: 'https://sepolia-rpc.scroll.io/',
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
      scrollSepolia: process.env.SCROLLSCAN_API_KEY
        ? process.env.SCROLLSCAN_API_KEY
        : '',
    },
    customChains: [
      {
        network: 'scrollSepolia',
        chainId: 534351,
        urls: {
          apiURL: 'https://sepolia-blockscout.scroll.io/api',
          browserURL: 'https://sepolia-blockscout.scroll.io/',
        },
      },
    ],
  },
  // preprocess: {
  //   eachLine: (hre) => ({
  //     transform: (line: string) => {
  //       if (line.match(/^\s*import /i)) {
  //         getRemappings().forEach(([find, replace]) => {
  //           if (line.match(find)) {
  //             line = line.replace(find, replace);
  //           }
  //         });
  //       }
  //       return line;
  //     },
  // }),
  // },
};

export default config;
