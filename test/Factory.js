const { ethers } = require("hardhat");
const { expect } = require("chai");

function expandTo18Decimals(n) {
  return BigInt(n * 10 ** 18);
}

const TOTAL_SUPPLY = expandTo18Decimals(10000);
const MINIMUM_LIQUIDITY = BigInt(100);

describe("features", function () {
  let factory, pair, token0, token1;

  let deployer, jane;
  beforeEach(async () => {
    [deployer, jane] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Factory");
    factory = await Factory.deploy(deployer.address);
    await factory.waitForDeployment();

    pair = await ethers.getContractFactory("Pair");

    const option0 = "Option1";
    const option1 = "Option2";

    //await factory.createPair(option0, option1);

    console.log(await factory.createPair(option0, option1));

    console.log(await factory.getPairAddress(option0, option1));
  });

  it("Should create pair ", async function () {
    expect(await factory.allPairsLength()).to.eq(1);
    //expect(await pair.token0()).to.eq(token0.address);
    //expect(await pair.token1()).to.eq(token1.address);
  });

  it("Should mint ", async function () {
    const token0Amount = expandTo18Decimals(2);
    const token1Amount = expandTo18Decimals(18);
    await token0.transfer(pair.address, token0Amount);
    await token1.transfer(pair.address, token1Amount);

    await pair.mint(deployer.address);

    // sqrt( t1 * t2 )
    const expectedLiquidity = expandTo18Decimals(6);
    expect(await pair.totalSupply()).to.eq(expectedLiquidity);

    expect(await token0.balanceOf(pair.address)).to.eq(token0Amount);
    expect(await token1.balanceOf(pair.address)).to.eq(token1Amount);
  });

  it("Should swap", async function () {
    const token0Amount = expandTo18Decimals(5);
    const token1Amount = expandTo18Decimals(10);
    await token0.transfer(pair.address, token0Amount, {
      gasLimit: 60000,
    });
    await token1.transfer(pair.address, token1Amount, {
      gasLimit: 60000,
    });

    await pair.mint(deployer.address, {
      gasLimit: 200000,
    });

    const swapAmount = expandTo18Decimals(1);

    const Preserves = await pair.getReserves();

    var amountInWithFee = swapAmount.mul(996);

    var numerator = amountInWithFee.mul(Preserves[1]);
    var denominator = Preserves[0].mul(1000).add(amountInWithFee);
    var amountOut = numerator / denominator;

    //const expectedOutputAmount = ethers.BigNumber.from("1662497915624478906");
    const expectedOutputAmount = ethers.BigNumber.from(String(amountOut));

    await token0.transfer(pair.address, swapAmount, {
      gasLimit: 60000,
    });

    await pair.swap(0, expectedOutputAmount, deployer.address, "0x", {
      gasLimit: 200000,
    });

    const reserves = await pair.getReserves();
    expect(reserves[0]).to.eq(token0Amount.add(swapAmount));
    expect(reserves[1]).to.eq(token1Amount.sub(expectedOutputAmount));
    expect(await token0.balanceOf(pair.address)).to.eq(
      token0Amount.add(swapAmount)
    );
    expect(await token1.balanceOf(pair.address)).to.eq(
      token1Amount.sub(expectedOutputAmount)
    );
    const totalSupplyToken0 = await token0.totalSupply();
    const totalSupplyToken1 = await token1.totalSupply();
    expect(await token0.balanceOf(deployer.address)).to.eq(
      totalSupplyToken0.sub(token0Amount).sub(swapAmount)
    );
    expect(await token1.balanceOf(deployer.address)).to.eq(
      totalSupplyToken1.sub(token1Amount).add(expectedOutputAmount)
    );
  });

  it("burn", async () => {
    const token0Amount = expandTo18Decimals(3);
    const token1Amount = expandTo18Decimals(3);

    await token0.transfer(pair.address, token0Amount, {
      gasLimit: 60000,
    });
    await token1.transfer(pair.address, token1Amount, {
      gasLimit: 60000,
    });

    await pair.mint(deployer.address, {
      gasLimit: 200000,
    });

    const expectedLiquidity = expandTo18Decimals(3);

    await pair.transfer(
      pair.address,
      expectedLiquidity.sub(MINIMUM_LIQUIDITY),
      {
        gasLimit: 60000,
      }
    );

    await pair.burn(deployer.address, {
      gasLimit: 200000,
    });

    expect(await pair.balanceOf(deployer.address)).to.eq(0);
    expect(await pair.totalSupply()).to.eq(MINIMUM_LIQUIDITY);
    expect(await token0.balanceOf(pair.address)).to.eq(1000);
    expect(await token1.balanceOf(pair.address)).to.eq(1000);
    const totalSupplyToken0 = await token0.totalSupply();
    const totalSupplyToken1 = await token1.totalSupply();
    expect(await token0.balanceOf(deployer.address)).to.eq(
      totalSupplyToken0.sub(1000)
    );
    expect(await token1.balanceOf(deployer.address)).to.eq(
      totalSupplyToken1.sub(1000)
    );
  });

  it("Should mint to another account", async function () {
    const token0Amount = expandTo18Decimals(2000);
    const token1Amount = expandTo18Decimals(2000);

    await token0.transfer(jane.address, token0Amount, {
      gasLimit: 60000,
    });

    await token1.transfer(jane.address, token1Amount, {
      gasLimit: 60000,
    });

    expect(await token0.balanceOf(jane.address)).to.eq(token0Amount);
    expect(await token1.balanceOf(jane.address)).to.eq(token1Amount);

    await token0.connect(jane).transfer(pair.address, token0Amount, {
      gasLimit: 60000,
    });

    await token1.connect(jane).transfer(pair.address, token1Amount, {
      gasLimit: 60000,
    });

    await pair.mint(jane.address, {
      gasLimit: 200000,
    });

    // sqrt( t1 * t2 )
    const expectedLiquidity = expandTo18Decimals(2000);
    expect(await pair.totalSupply()).to.eq(expectedLiquidity);

    expect(await token0.balanceOf(pair.address)).to.eq(token0Amount);
    expect(await token1.balanceOf(pair.address)).to.eq(token1Amount);
  });
});
