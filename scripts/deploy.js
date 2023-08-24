// const hre = require("hardhat");

// async function main() {

//   const rate = hre.ethers.parseEther("0.0000055");

//   const crowdSale = await hre.ethers.deployContract("Crowdsale", [unlockTime], {
//     value: lockedAmount,
//   });

//   await lock.waitForDeployment();

//   console.log(
//     `Lock with ${ethers.formatEther(
//       lockedAmount
//     )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
//   );
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });

const hre = require("hardhat");

async function main() {
  //getting the contract from the hardhat contract

  const ercTokenAddress = "0xB5206E229fA7004122191335e3068bAF8DdaE21C";
  // const ercTokenAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

  const TokenA = await ethers.getContractFactory("TokenA");
  const tokenA = await TokenA.deploy();
  await tokenA.mint(ercTokenAddress, 9000000000000000000);
  console.log("rating deployed to:", tokenA.address);

  // const newArtiste = await rateArtiste.getArtiste(1);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
