import { ethers } from "hardhat";
import { }

async function main() {

    // Set up the contract factory and signer
    const WorldNFT = await ethers.deployContract("GreeterOperator");

    // Deploy the contract
    await WorldNFT.waitForDeployment();

    console.log("WorldNFT deployed to:", WorldNFT.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});