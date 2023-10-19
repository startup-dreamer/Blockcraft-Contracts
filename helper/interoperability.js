const ethers = require('ethers');
const sender = require('../artifacts/contracts/wormhole-integrations/WorldNFT-Sender.sol/Greeter.json');
const reciver = require('../artifacts/contracts/wormhole-integrations/Wormhole-Reciever.sol/GreeterOperator.json');

const SENDER_ADDRESS = '0xD8AaDe0b7547DD8a27C7B01D5BaA0bd9eaBb5C22';
const RECEIVER_ADDRESS = '0x4B48Bb27Cb4dD6955Ab00Aee5af744d082Bd962f';
const SENDER_ABI = reciver.abi;
const RECEIVER_ABI = sender.abi;

async function main() {
    const privateKey = '695443873d058db7e263d01779d068b2fdb1863556ad7d14c953de97dbe35119'; // replace with your private key
    const scroll_provider = new ethers.providers.JsonRpcProvider('https://sepolia-rpc.scroll.io/');
    const scroll_signer = new ethers.Wallet(privateKey, scroll_provider);
    const receiver_contract = new ethers.Contract(RECEIVER_ADDRESS, RECEIVER_ABI, scroll_signer);

    const sepolia_provider = new ethers.providers.JsonRpcProvider('https://sepolia.infura.io/v3/33918abda18c4845916f0c66304fa500');
    const sepolia_signer = new ethers.Wallet(privateKey, sepolia_provider);
    const sender_contract = new ethers.Contract(SENDER_ADDRESS, SENDER_ABI, sepolia_signer);

    const tx = await sender_contract.executeFunctionCrosschain(
        '0x50c7d3e7f7c656493D1D76aaa1a836CedfCBB16A',
        RECEIVER_ADDRESS,
        1000000,
        "fuck you!",
        5000
    );
    await tx.wait();

    console.log(await receiver_contract.greeting());
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});