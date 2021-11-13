import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-watcher";
import "hardhat-tracer";
// import "@typechain/hardhat";

dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const config: HardhatUserConfig = {
  defaultNetwork: "mumbai",
  networks: {
    mumbai: {
      url: process.env.API_URL || "",
      accounts: {
        mnemonic: process.env.MNEMONIC || "",
        initialIndex: parseInt(process.env.INITIAL_INDEX || "0"),
      },
      //gas: 12500000,
    },
    hardhat: {
      forking: {
        url: process.env.API_URL || "",
      },
      accounts: {
        mnemonic: process.env.MNEMONIC || "",
        // initialIndex: parseInt(process.env.INITIAL_INDEX || "0"),
        accountsBalance: "1000000000000000000"
      },
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  watcher: {
    compile: {
      tasks: ["compile"],
    },
    test: {
      tasks: [{ command: 'test', params: { testFiles: ['{path}'] } }],
      files: ['./test/**/*'],
      verbose: false
    }
  },
  mocha: {
    timeout: 20000
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
