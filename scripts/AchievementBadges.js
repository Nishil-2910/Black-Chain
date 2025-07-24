const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying with address:", deployer.address);

  const AchievementBadges = await ethers.getContractFactory("AchievementBadges");

  // Deploy with the URI as a constructor argument
  const achievementBadges = await AchievementBadges.deploy("https://example.com/api/token/{id}.json");

  await achievementBadges.waitForDeployment();
  
  console.log("AchievementBadges deployed to:", await achievementBadges.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});