require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  gasReporter: {
    currency: "CHF",
    gasPrice: 21,
    enabled: true,
  },
  networks: {
    tronDev: {
      accounts: [],
    }
  }
};
