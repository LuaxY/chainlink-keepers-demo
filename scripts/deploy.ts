import { ethers } from "hardhat";

async function main() {
  const Token = await ethers.getContractFactory("SuperToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log("SuperToken deployed at:", token.address);

  const NFT = await ethers.getContractFactory("SuperNFT");
  const nft = await NFT.deploy(token.address);
  await nft.deployed();
  console.log("SuperNFT deployed at:", nft.address);

  // const Token = await ethers.getContractFactory("SuperToken");
  // const token = Token.attach("0x6bbb862e9C40aFCef79c5E5BEb01eF66A6B45B8a");

  // const NFT = await ethers.getContractFactory("SuperNFT");
  // const nft = NFT.attach("0x7E4f4316a84db455EbC0E7F2AcfD2fF206fC005D");

  await token.transfer(nft.address, ethers.utils.parseUnits("100"));

  const LINK_ADDRESS = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
  const ERC20 = await ethers.getContractFactory("ERC20");
  const LINK = ERC20.attach(LINK_ADDRESS);
  await LINK.transfer(nft.address, ethers.utils.parseUnits("0.0005"));

  console.log(`hh verify --contract contracts/Token.sol:SuperToken ${token.address}`);
  console.log(`hh verify --contract contracts/NFT.sol:SuperNFT ${nft.address} ${token.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
