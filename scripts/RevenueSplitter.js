const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying RevenueSplitter with account:", deployer.address);

  // Replace these addresses and values accordingly
  const educator = "0x79F8D2cFCC181fb9fdECfA568C305e6AC8ECFe68";
  const platform = "0x9C67ddDE65bB6400e9Ce53e10C03287c558b6E12";
  const sponsor = "0xBA18B7A73B2dE33DF250FDA3aCFAba98649619a6";

  // Set the shares (in basis points = 10000 = 100%)
  const educatorShare = 5000;  // 50%
  const platformShare = 4000;  // 40%
  const sponsorShare = 1000;   // 10%

  const RevenueSplitter = await ethers.getContractFactory("RevenueSplitter");
  const splitter = await RevenueSplitter.deploy(
    educator,
    platform,
    sponsor,
    educatorShare,
    platformShare,
    sponsorShare
  );

  await splitter.waitForDeployment();

  console.log("RevenueSplitter deployed at:", splitter.target);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
