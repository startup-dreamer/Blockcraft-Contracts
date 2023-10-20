import { ethers } from "hardhat";
import { WORLD_NFT_ADDRESS, SCROLL_MESSENGER_ADDRESS_POLYGON, SCROLL_MESSENGER_ADDRESS_OPTIMISM, SCROLL_MESSENGER_ADDRESS_SEPOLIA } from "./constants";

async function main() {

    // Set up the contract factory and signer
    const WorldNFTOperator = await ethers.deployContract("WorldNFTOperator");

    // Deploy the contract
    await WorldNFTOperator.waitForDeployment();

    console.log("WorldNFT deployed to:", WorldNFTOperator.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});