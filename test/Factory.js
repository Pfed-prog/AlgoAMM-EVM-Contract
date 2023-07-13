const { ethers } = require("hardhat");
const { expect } = require("chai");

function expandTo18Decimals(n) {
  return BigInt(n * 10 ** 18);
}

const TOTAL_SUPPLY = expandTo18Decimals(10000);

describe("features", function () {
  let factory, pair, pairAddress, option0, option1, reserveToken;

  let deployer, jane;
  beforeEach(async () => {
    [deployer, jane] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Factory");
    factory = await Factory.deploy(deployer.address);
    await factory.waitForDeployment();

    const MyPair = await ethers.getContractFactory("Pair");

    const MyERC20 = await ethers.getContractFactory("Token");

    reserveToken = await MyERC20.deploy("Gold", "GLD");
    await reserveToken.waitForDeployment();

    // console.log(reserveToken.target);

    option0 = "Option1";
    option1 = "Option2";

    await factory.createPair(option0, option1, reserveToken.target);

    pairAddress = await factory.getPairAddress(option0, option1);
    pair = MyPair.attach(pairAddress);
  });

  it("Should create pair", async function () {
    expect(await factory.allPairsLength()).to.eq(1);
    expect(await pair.option0()).to.eq(option0);
    expect(await pair.option1()).to.eq(option1);
  });
});
