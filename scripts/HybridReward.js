const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const HybridReward = await ethers.getContractFactory("HybridReward");

  const hybridReward = await HybridReward.deploy("https://example.com/api/token/{id}.json");

  const deployedHybridReward = await hybridReward.waitForDeployment();

  console.log("HybridReward contract deployed to:", deployedHybridReward.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
