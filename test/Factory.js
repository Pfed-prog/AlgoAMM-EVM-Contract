const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("features", function () {
  let factory, pair, pairAddress, option0, option1;

  let deployer, jane;
  beforeEach(async () => {
    [deployer, jane] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Factory");
    factory = await Factory.deploy(deployer.address);
    await factory.waitForDeployment();

    const MyPair = await ethers.getContractFactory("Pair");

    option0 = "Option1";
    option1 = "Option2";

    const factoryTx = await factory.createPair(option0, option1);
    await factoryTx.wait();

    pairAddress = await factory.getPairAddress(option0, option1);
    pair = MyPair.attach(pairAddress);
  });

  it("Should create pair", async function () {
    expect(await factory.allPairsLength()).to.eq(1);
    expect(await pair.option0()).to.eq(option0);
    expect(await pair.option1()).to.eq(option1);
  });
});
