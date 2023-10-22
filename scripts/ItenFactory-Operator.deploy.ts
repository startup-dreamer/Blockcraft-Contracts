import { ethers, run } from "hardhat";
import { SCROLL_MESSENGER_ADDRESS_SEPOLIA, ITEM_FACTORY_ADDRESS } from "./constants";

async function main() {
    Set up the contract factory and signer
    const ItemFactoryOperator = await ethers.deployContract("ItemFactoryOperator", [ITEM_FACTORY_ADDRESS, SCROLL_MESSENGER_ADDRESS_SEPOLIA]);

    // Deploy the contract
    await ItemFactoryOperator.waitForDeployment();
    const contractAddress = ItemFactoryOperator.target;

    console.log("Operator is deployed to:", contractAddress);

    setTimeout(async () => {}, 30000);

    await run("verify:verify", {
        address: contractAddress,
        constructorArguments: [ITEM_FACTORY_ADDRESS, SCROLL_MESSENGER_ADDRESS_SEPOLIA],
        contract: 'contracts/Scroll-CrossChain/ItemFactory-Operator.sol:ItemFactoryOperator',
      });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  // 0x62A9AA8Eae2BCEBc42b93b73e977AC748EA81e66  