const ethers = require('ethers');
const ItemFactory = require('./ItemsFactory.json');
const Item = require('./Item.json');
const { log } = require('console');

async function fetchUserItemMetadata(userAddress) {
    const provider = new ethers.providers.JsonRpcProvider('https://sepolia-rpc.scroll.io/');
    // ('https://sepolia-rpc.scroll.io/');
    const contractAddress = '0xb07001587e89690A287AC4c59375952F02e3a3dc';
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

// fetchUserItemMetadata('0x1F037c23c1729edC39184fe0156750482C8fe5e2').catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
// });

async function getAllNFTsTotalSupplyItemURI() {
    const provider = new ethers.providers.JsonRpcProvider('https://sepolia-rpc.scroll.io/');
    // ('https://sepolia-rpc.scroll.io/');
    const contractAddress = '0xb07001587e89690A287AC4c59375952F02e3a3dc';
    const contractAbi = ItemFactory.abi; // Replace with your actual ABI
    const itemAbi = Item.abi; // Replace with your actual ABI
    const contract = new ethers.Contract(contractAddress, contractAbi, provider);

    const totalItems = await contract._totalItems();
    let itemAdditionalData = [];

    for (let i = 1 ; i <= totalItems; i++) {
        const itemNumToItem = await contract.itemNumToItem(i);
        const itemAddress = itemNumToItem.itemAddress;
        const itemTotalSupply = itemNumToItem.totalSupply;
        const itemURI = itemNumToItem.itemURI;

        
        const json = {
            itemAddress: itemAddress,
            itemTotalSupply: Number(itemTotalSupply?._hex),
            cid: itemURI
        };

        itemAdditionalData.push(JSON.stringify(json));
    }
    log(itemAdditionalData);
}

getAllNFTsTotalSupplyItemURI().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});