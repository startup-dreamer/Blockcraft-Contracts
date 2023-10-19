import { ethers } from "hardhat";
import { verifyContract, VerifyContractParams } from "../utils/verify";

async function sender() {
    // Set up the deployment parameters
    const name = "WorldNFT";
    const symbol = "WORLD";

    // Set up the contract factory and signer
    const WorldNFT = await ethers.deployContract("Greeter");

    // Deploy the contract
    await WorldNFT.waitForDeployment();

    console.log("WorldNFT deployed to:", WorldNFT.target);
}

// sender().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
// });

async function reciever() {
    // Set up the deployment parameters
    const name = "WorldNFT";
    const symbol = "WORLD";

    // Set up the contract factory and signer
    const WorldNFT = await ethers.deployContract("GreeterOperator");

    // Deploy the contract
    await WorldNFT.waitForDeployment();
    
    const verifyPera: VerifyContractParams = {
        contractAddress: WorldNFT.target.toString(),
        args: [],
        contractPath: 'GMX-V2-LP-Vault/contracts/wormhole-integrations/Wormhole-Reciever.sol:GreeterOperator',
    };

    verifyContract(verifyPera);

    console.log("WorldNFT deployed to:", WorldNFT.target);
}

reciever().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
