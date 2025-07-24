const { ethers } = require("ethers");
require("dotenv").config();

const ABI = [
  {
    "inputs": [
      { "internalType": "string", "name": "name", "type": "string" },
      { "internalType": "string", "name": "description", "type": "string" }
    ],
    "name": "createBadge",
    "outputs": [
      { "internalType": "uint256", "name": "", "type": "uint256" }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

const BADGE_CONTRACT_ADDRESS = "0x0E3F1Ed2320950B239F0F3Ddb08E908B89FcF003";

async function createBadge(name, description) {
  const provider = new ethers.JsonRpcProvider(process.env.BASE_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(BADGE_CONTRACT_ADDRESS, ABI, wallet);

  console.log(`📛 Creating badge: ${name} - ${description}`);
  try {
    const tx = await contract.createBadge(name, description);
    const receipt = await tx.wait();
    console.log("✅ Badge created successfully!");
    console.log("🔁 Transaction Hash:", receipt.hash);
  } catch (err) {
    console.error("❌ Failed to create badge:", err.reason || err.message);
  }
}

// Usage: node createBadge.js "Badge Name" "Badge Description"
const name = process.argv[2];
const description = process.argv[3];

if (!name || !description) {
  console.error("⚠️  Usage: node createBadge.js \"Badge Name\" \"Badge Description\"");
  process.exit(1);
}

createBadge(name, description);
