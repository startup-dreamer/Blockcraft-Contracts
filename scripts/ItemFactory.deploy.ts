import { ethers, run } from "hardhat";

async function main() {
    // Set up the contract factory and signer
    const ItemFactory = await ethers.deployContract("ItemFactory");

    // Deploy the contract
    await ItemFactory.waitForDeployment();
    const contractAddress = ItemFactory.target;

    console.log("WorldNFT deployed to:", contractAddress);

    setTimeout(async () => {}, 30000);

    await run("verify:verify", {
        address: contractAddress,
        constructorArguments: [],
        contract: 'contracts/ItemFactory.sol:ItemFactory',
      });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  