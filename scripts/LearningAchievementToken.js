const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  
  const LearningAchievementToken = await hre.ethers.getContractFactory("LearningAchievementToken");

  const learningAchievementToken = await LearningAchievementToken.deploy();

  await learningAchievementToken.waitForDeployment();

  const address = await learningAchievementToken.getAddress();
  
  console.log("LearningAchievementToken deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})