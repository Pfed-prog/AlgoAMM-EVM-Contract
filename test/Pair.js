const { ethers } = require("hardhat");
const { expect } = require("chai");

function expandTo18Decimals(n) {
  return BigInt(n * 10 ** 18);
}

const TOTAL_SUPPLY = expandTo18Decimals(10000);

describe("Pair", function () {
  let factory,
    pair,
    pairAddress,
    option0,
    option1,
    reserveToken,
    token0,
    token1;

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
    reserveToken.mint(deployer.address, TOTAL_SUPPLY);

    option0 = "Option1";
    option1 = "Option2";

    await factory.createPair(option0, option1, reserveToken.target);

    pairAddress = await factory.getPairAddress(option0, option1);
    pair = MyPair.attach(pairAddress);

    const token0Address = await pair.token0Address();
    token0 = MyERC20.attach(token0Address);

    const token1Address = await pair.token1Address();
    token1 = MyERC20.attach(token1Address);
  });

  it("Should mint No", async function () {
    const number = 100;
    const tokenAmount = expandTo18Decimals(number);

    await reserveToken.transfer(jane.address, tokenAmount);

    await reserveToken.connect(jane).approve(pairAddress, tokenAmount);
    
    await pair.connect(jane).voteNo(tokenAmount);

    expect(await reserveToken.balanceOf(pairAddress)).to.eq(tokenAmount);
    expect(await token0.balanceOf(jane.address)).to.eq(tokenAmount);
  });

  it("Should mint Yes", async function () {
    const number = 100;
    const tokenAmount = expandTo18Decimals(number);

    await reserveToken.transfer(jane.address, tokenAmount);

    await reserveToken.connect(jane).approve(pairAddress, tokenAmount);

    await pair.connect(jane).voteYes(tokenAmount);

    expect(await reserveToken.balanceOf(pairAddress)).to.eq(tokenAmount);
    expect(await token1.balanceOf(jane.address)).to.eq(tokenAmount);
  });

  it("Should mint Equally", async function () {
    const number = 100;
    const tokenAmount = expandTo18Decimals(number);
    const div2Number = BigInt(Number(tokenAmount)  / 2);

    await reserveToken.transfer(jane.address, tokenAmount);

    await reserveToken.connect(jane).approve(pairAddress, tokenAmount);

    await pair.connect(jane).voteEqually(tokenAmount);

    expect(await reserveToken.balanceOf(pairAddress)).to.eq(tokenAmount);
    expect(await token0.balanceOf(jane.address)).to.eq(div2Number);
    expect(await token1.balanceOf(jane.address)).to.eq(div2Number);
  });

  it("Event Resolves", async function () {
    await factory.resolveEvent(pairAddress, 2);
    
    expect(await pair.eventResolved()).to.eq(1);
    expect(await pair.eventResult()).to.eq(2);
  });

  it("Redeems. First option wins", async function () {
    const number = 100;
    const tokenAmount = expandTo18Decimals(number);
    const div2Number = BigInt(Number(tokenAmount)  / 2);

    await reserveToken.transfer(jane.address, tokenAmount);

    await reserveToken.connect(jane).approve(pairAddress, tokenAmount);

    await pair.connect(jane).voteEqually(tokenAmount);

    await factory.resolveEvent(pairAddress, 0)

    await token0.connect(jane).approve(pairAddress, div2Number);

    await pair.connect(jane).redeem(div2Number);

    expect(await reserveToken.balanceOf(pairAddress)).to.eq(0);
    expect(await token0.balanceOf(jane.address)).to.eq(0);
    expect(await reserveToken.balanceOf(jane.address)).to.eq(tokenAmount);
  });

  it("Redeems. Second option wins", async function () {
    const number = 100;
    const tokenAmount = expandTo18Decimals(number);
    const div2Number = BigInt(Number(tokenAmount)  / 2);

    await reserveToken.transfer(jane.address, tokenAmount);

    await reserveToken.connect(jane).approve(pairAddress, tokenAmount);

    await pair.connect(jane).voteEqually(tokenAmount);

    await factory.resolveEvent(pairAddress, 1)

    await token1.connect(jane).approve(pairAddress, div2Number);

    await pair.connect(jane).redeem(div2Number);

    expect(await reserveToken.balanceOf(pairAddress)).to.eq(0);
    expect(await token1.balanceOf(jane.address)).to.eq(0);
    expect(await reserveToken.balanceOf(jane.address)).to.eq(tokenAmount);
  });

});
