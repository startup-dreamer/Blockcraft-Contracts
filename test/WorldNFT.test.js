const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WorldNFT", function () {
  let WorldNFT;
  let worldNFT;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    WorldNFT = await ethers.getContractFactory("WorldNFT");
    worldNFT = await WorldNFT.deploy("WorldNFT", "WNFT", "A contract for creating World NFTs");
    await worldNFT.deployed();
  });

  describe("createWorld", function () {
    it("should create a new World NFT", async function () {
      const tokenURI = "ipfs://QmXJZJ1ZJ7JjJzJzJzJzJzJzJzJzJzJzJzJzJzJzJzJzJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 0;
      expect(await worldNFT.ownerOf(tokenId)).to.equal(owner.address);
      expect(await worldNFT.tokenURI(tokenId)).to.equal(tokenURI);
    });
  });

  describe("fetchMetadata", function () {
    it("should return the metadata for a World NFT", async function () {
      const tokenURI = "ipfs://QmXJZJ1ZJ7JjJzJzJzJzJzJzJzJzJzJzJzJzJzJzJzJzJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 0;
      const metadata = await worldNFT.fetchMetadata(owner.address, tokenId);
      expect(metadata).to.equal("data:application/json;base64,eyJua...",
        "Metadata does not match expected value");
    });
  });

  describe("setTokenURI", function () {
    it("should update the token URI for a World NFT", async function () {
      const tokenURI = "ipfs://QmXJZJ1ZJ7JjJzJzJzJzJzJzJzJzJzJzJzJzJzJzJzJzJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 0;
      const newTokenURI = "ipfs://QmYKZK1ZK7KkKyKyKyKyKyKyKyKyKyKyKyKyKyKyKyKyK";
      await worldNFT.setTokenURI(owner.address, tokenId, newTokenURI);
      expect(await worldNFT.tokenURI(tokenId)).to.equal(newTokenURI);
    });
  });
});