const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying PurchaseReceiptNFT with account:", deployer.address);

  const PurchaseReceiptNFT = await ethers.getContractFactory("PurchaseReceiptNFT");
  const contract = await PurchaseReceiptNFT.deploy();

  await contract.waitForDeployment();

  console.log("PurchaseReceiptNFT deployed to:", await contract.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment error:", error);
    process.exit(1);
  });
