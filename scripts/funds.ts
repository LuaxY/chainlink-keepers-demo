import { ethers } from "hardhat";

async function main() {
  const accounts = await ethers.getSigners();
  const master = accounts[0];
  const accountsToFund = 10;

  for (let i = 1; i <= accountsToFund; i++) {
    console.log((await master.sendTransaction({
      to: accounts[i].address,
      value: ethers.utils.parseEther("0.02"),
    })).hash);
  }

  for (let i = 1; i <= accountsToFund; i++) {
    console.log(accounts[i].address, await accounts[i].getBalance());
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
