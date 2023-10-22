import { ethers, run } from "hardhat";
import { SCROLL_MESSENGER_ADDRESS_SEPOLIA, WORLD_NFT_ADDRESS } from "./constants";

async function main() {
    // Set up the contract factory and signer
    const WorldNFTOperator = await ethers.deployContract("WorldNFTOperator", [WORLD_NFT_ADDRESS, SCROLL_MESSENGER_ADDRESS_SEPOLIA]);

    // Deploy the contract
    await WorldNFTOperator.waitForDeployment();
    const contractAddress = WorldNFTOperator.target;

    console.log("Operator is deployed to:", contractAddress);

    setTimeout(async () => {}, 30000);

    await run("verify:verify", {
        address: contractAddress,
        constructorArguments: [WORLD_NFT_ADDRESS, SCROLL_MESSENGER_ADDRESS_SEPOLIA],
        contract: 'contracts/Scroll-CrossChain/WorldNFT-Operator.sol:WorldNFTOperator',
      });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  