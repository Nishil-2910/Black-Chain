const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("ethers");
const PinataSDK = require("@pinata/sdk");
require("dotenv").config();

const pinata = new PinataSDK({ pinataJWTKey: process.env.PINATA_JWT });
const CONTRACT_ADDRESS = process.env.BADGE_CONTRACT_ADDRESS;

// 🧠 ABI directly embedded here:
const ABI = [
  {
    "inputs": [{ "internalType": "string", "name": "uri", "type": "string" }],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": true, "internalType": "uint256", "name": "badgeId", "type": "uint256" },
      { "indexed": true, "internalType": "address", "name": "to", "type": "address" },
      { "indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256" },
      { "indexed": false, "internalType": "string", "name": "name", "type": "string" },
      { "indexed": false, "internalType": "string", "name": "description", "type": "string" }
    ],
    "name": "BadgeMinted",
    "type": "event"
  },
  {
    "inputs": [
      { "internalType": "string", "name": "name", "type": "string" },
      { "internalType": "string", "name": "description", "type": "string" }
    ],
    "name": "createBadge",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "badgeId", "type": "uint256" }],
    "name": "getBadge",
    "outputs": [
      {
        "components": [
          { "internalType": "string", "name": "name", "type": "string" },
          { "internalType": "string", "name": "description", "type": "string" }
        ],
        "internalType": "struct AchievementBadges.Badge",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "to", "type": "address" },
      { "internalType": "uint256", "name": "badgeId", "type": "uint256" },
      { "internalType": "uint256", "name": "amount", "type": "uint256" }
    ],
    "name": "mintBadge",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "string", "name": "newuri", "type": "string" }],
    "name": "setURI",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "badgeId", "type": "uint256" }],
    "name": "badgeExists",
    "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
    "stateMutability": "view",
    "type": "function"
  }
];

async function main() {
  console.log("🔄 Pinning images to IPFS...");
  const imagesFolder = path.join(__dirname, "../ipfs/images");
  const imageRes = await pinata.pinFromFS(imagesFolder, {
    pinataMetadata: { name: "badge-images" },
  });
  const imageCID = imageRes.IpfsHash;
  console.log("📸 Images pinned  →", imageCID);

  const metadataFolder = path.join(__dirname, "../ipfs/metadata");
  fs.ensureDirSync(metadataFolder);
  const files = fs.readdirSync(imagesFolder);

  console.log("📝 Generating metadata files...");
  files.forEach((file) => {
    const badgeId = parseInt(file.split(".")[0], 10);
    const hexId = badgeId.toString(16).padStart(64, "0");

    const metadata = {
      name: `Badge #${badgeId}`,
      description: `Description for Badge #${badgeId}`,
      image: `ipfs://${imageCID}/${file}`,
      attributes: [
        { trait_type: "Badge ID", value: badgeId },
        { trait_type: "Level", value: "Basic" },
      ],
    };

    const outputPath = path.join(metadataFolder, `${hexId}.json`);
    fs.writeFileSync(outputPath, JSON.stringify(metadata, null, 2));
  });
  console.log("📝 Metadata files written →", metadataFolder);

  console.log("🔄 Pinning metadata to IPFS...");
  const metadataRes = await pinata.pinFromFS(metadataFolder, {
    pinataMetadata: { name: "badge-metadata" },
  });
  const metadataCID = metadataRes.IpfsHash;
  console.log("🧾 Metadata pinned →", metadataCID);

  const baseURI = `ipfs://${metadataCID}/{id}.json`;

  // Connect to contract using ethers + embedded ABI
  console.log("🔌 Connecting to contract...");
  const provider = new ethers.JsonRpcProvider(process.env.BASE_RPC_URL); // Your RPC URL
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);

  console.log("📨 Updating contract URI...");
  const tx = await contract.setURI(baseURI);
  await tx.wait();
  console.log("✅ Contract base URI updated to:", baseURI);
}

main().catch((err) => {
  console.error("❌ Error:", err);
  process.exit(1);
});
