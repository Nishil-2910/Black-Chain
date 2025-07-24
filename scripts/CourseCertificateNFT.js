const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  
  const CertificateNFT = await hre.ethers.getContractFactory("CertificateNFT");

  const certificateNFT = await CertificateNFT.deploy();

  await certificateNFT.waitForDeployment();

  const address = await certificateNFT.getAddress();
  
  console.log("CertificateNFT deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});