import { ethers, run } from "hardhat";
import { WORLD_NFT_NAME, WORLD_NFT_SYMBOL } from "./constants";

async function main() {
    const args = [WORLD_NFT_NAME, WORLD_NFT_SYMBOL];
    // Set up the contract factory and signer
    const WorldNFT = await ethers.deployContract("WorldNFT", args);

    // Deploy the contract
    await WorldNFT.waitForDeployment();

    const contractAddress = WorldNFT.target;

    console.log("WorldNFT deployed to:", contractAddress);
    setTimeout(async () => {}, 30000);
    await run("verify:verify", {
        address: contractAddress,
        constructorArguments: args,
        contract: 'contracts/WorldNFT.sol:WorldNFT',
      });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  