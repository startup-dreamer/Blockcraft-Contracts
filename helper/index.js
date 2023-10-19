const ethers = require('ethers');
const ItemFactory = require('./ItemsFactory.json');
const Item = require('./Item.json');
const { log } = require('console');

async function fetchUserItemMetadata(userAddress) {
    const provider = new ethers.providers.JsonRpcProvider('https://sepolia-rpc.scroll.io/');
    // ('https://sepolia-rpc.scroll.io/');
    const contractAddress = '0x13949BB484C058530B25C0e5D75Cb6B7c2AD19Af';
    const contractAbi = ItemFactory.abi; // Replace with your actual ABI
    const itemAbi = Item.abi; // Replace with your actual ABI
    const contract = new ethers.Contract(contractAddress, contractAbi, provider);

    const totalItems = await contract._totalItems();
    let itemMetadata = [];

    for (let i = 1; i <= totalItems; i++) {
        const itemNumToItem = await contract.itemNumToItem(i);
        const itemTotalSupply = itemNumToItem.totalSupply;
        
        const itemAddress = itemNumToItem.itemAddress;
        const itemContract = new ethers.Contract(itemAddress, itemAbi, provider);
        
        for (let j = 1; j <= itemTotalSupply; j++) {
            const owner = await itemContract.ownerOf(j);

            if (owner === userAddress) {
                const ipfsCid = await itemContract.tokenURI(j);
                const name = await itemContract.name();

                const json = {
                    name: name,
                    cid: ipfsCid
                };

                itemMetadata.push(JSON.stringify(json));
            }
        }
    }
    log(itemMetadata);
    return itemMetadata;
}

fetchUserItemMetadata('0xd2B93E349EbA5FF8673Be42b30Fd7C17904E0401').catch((error) => {
    console.error(error);
    process.exitCode = 1;
});