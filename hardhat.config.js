require("@nomicfoundation/hardhat-toolbox");

// /** @type import('hardhat/config').HardhatUserConfig */

// module.exports = {
// };
// require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
const fs = require("fs");
// require("hardhat-deploy");

const BNB_TEST_PRIVATE_KEY = process.env.BNB_TEST_PRIVATE_KEY;
const BNB_RPC_URL = process.env.BNB_TEST_RPC;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    // bsc: {
    //   url: "https://bsc-dataseed1.defibit.io/",
    //   chainId: 56,
    //   accounts: [NEXT_PUBLIC_PRIVATE_KEY],
    // },
    bsc: {
      url: BNB_RPC_URL,
      chainId: 97,
      accounts: [BNB_TEST_PRIVATE_KEY],
      gasLimit: 60000000, // Network block gasLimit
    },
  },

  solidity: "0.8.19",
};
