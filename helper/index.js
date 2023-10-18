const ethers = require('ethers');
const ItemFactory = require('./ItemsFactory.json');
const Item = require('./Item.json');
const { log } = require('console');

async function fetchUserItemMetadata(userAddress) {
    const provider = new ethers.providers.JsonRpcProvider('https://sepolia-rpc.scroll.io/');  
    // ('https://sepolia-rpc.scroll.io/');
    const contractAddress = '0x53Fda8077D6014B111729385Cfd8BBF21Fff5ea7';
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

fetchUserItemMetadata('0x0F27E22e136635613143Be0dc76a3c243700D6b8').catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });