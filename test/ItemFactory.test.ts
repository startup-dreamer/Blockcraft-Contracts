import { expect } from "chai";
import { ethers } from "hardhat";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import type { WorldNFT } from "../typechain";

describe("WorldNFT", function () {
  let WorldNFT: WorldNFT;
  let worldNFT: WorldNFT;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;
  let addrs: SignerWithAddress[];

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    WorldNFT = await ethers.getContractFactory("WorldNFT");
    worldNFT = await WorldNFT.deploy("My WorldNFT", "WORLD", "My WorldNFT description");
    await worldNFT.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await worldNFT.owner()).to.equal(owner.address);
    });

    it("Should set the right name", async function () {
      expect(await worldNFT.name()).to.equal("My WorldNFT");
    });

    it("Should set the right symbol", async function () {
      expect(await worldNFT.symbol()).to.equal("WORLD");
    });

    it("Should set the right description", async function () {
      expect(await worldNFT.description()).to.equal("My WorldNFT description");
    });
  });

  describe("createWorld", function () {
    it("Should create a new world NFT", async function () {
      const tokenURI = "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 1;
      expect(await worldNFT.ownerOf(tokenId)).to.equal(owner.address);
      expect(await worldNFT.tokenURI(tokenId)).to.equal(tokenURI);
    });
  });

  describe("fetchMetadata", function () {
    it("Should fetch the metadata of an existing world NFT", async function () {
      const tokenURI = "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 1;
      const metadata = await worldNFT.fetchMetadata(owner.address, tokenId);
      expect(metadata).to.equal(`data:application/json;base64,eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.${Buffer.from(`{"name": "My WorldNFT","description": "My WorldNFT description","image": "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ"}`).toString('base64')}`);
    });

    it("Should fail if the token does not exist for the user", async function () {
      const tokenURI = "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 1;
      await expect(worldNFT.fetchMetadata(addr1.address, tokenId)).to.be.revertedWith("Token does not exist for this user");
    });
  });

  describe("updateTokenURI", function () {
    it("Should update the token URI of an existing world NFT", async function () {
      const tokenURI = "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 1;
      const newTokenURI = "ipfs://QmYK9K4Kv8K3K5dPv7d7dK5DK5dK5dK5dK5dK5dK5dK5dK";
      await worldNFT.updateTokenURI(owner.address, tokenId, newTokenURI);
      expect(await worldNFT.tokenURI(tokenId)).to.equal(newTokenURI);
    });

    it("Should fail if the user is not the owner of the token", async function () {
      const tokenURI = "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 1;
      const newTokenURI = "ipfs://QmYK9K4Kv8K3K5dPv7d7dK5DK5dK5dK5dK5dK5dK5dK5dK";
      await expect(worldNFT.updateTokenURI(addr1.address, tokenId, newTokenURI)).to.be.revertedWith("You are not the owner of this token");
    });

    it("Should fail if the token does not exist for the user", async function () {
      const tokenURI = "ipfs://QmXJ8J3Jv9J4J5cQv6z5zJ5ZJ5zJ5zJ5zJ5zJ5zJ5zJ5zJ";
      await worldNFT.createWorld(tokenURI);
      const tokenId = 1;
      const newTokenURI = "ipfs://QmYK9K4Kv8K3K5dPv7d7dK5DK5dK5dK5dK5dK5dK5dK5dK";
      await expect(worldNFT.updateTokenURI(addr1.address, tokenId, newTokenURI)).to.be.revertedWith("Token does not exist for this user");
    });
  });
});