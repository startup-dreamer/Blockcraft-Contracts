import { ethers } from "hardhat";
import { verifyContract, VerifyContractParams } from "../utils/verify";

async function main() {
    // Set up the contract factory and signer
    const WorldNFT = await ethers.deployContract("ItemFactory");

    // Deploy the contract
    await WorldNFT.waitForDeployment();

    const verifyPera: VerifyContractParams = {
        contractAddress: WorldNFT.target.toString(),
        args: [name, symbol],
        contractPath: "../contracts/WorldNFT.sol:WorldNFT",
    };

    verifyContract(verifyPera);

    console.log("WorldNFT deployed to:", WorldNFT.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  