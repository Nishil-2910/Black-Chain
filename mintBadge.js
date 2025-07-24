const { ethers } = require("ethers");
require("dotenv").config();

const ABI = [
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
    "inputs": [
      { "internalType": "uint256", "name": "badgeId", "type": "uint256" }
    ],
    "name": "badgeExists",
    "outputs": [
      { "internalType": "bool", "name": "", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  }
];



const provider = new ethers.JsonRpcProvider(process.env.BASE_RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const contract = new ethers.Contract(process.env.BADGE_CONTRACT_ADDRESS, ABI, wallet);

async function mintBadge(to, badgeId, amount = 1) {
  console.log("🔐 Wallet Address (Signer):", wallet.address);
  console.log("📄 Contract Address:", contract.target || contract.address);
  console.log("🎯 Minting to:", to);
  console.log("🏷️ Badge ID:", badgeId);
  console.log("🔢 Amount:", amount);

  try {
    const code = await provider.getCode(contract.target || contract.address);
    if (code === "0x") {
      throw new Error("🚫 No contract deployed at this address.");
    }

    const tx = await contract.mintBadge(to, badgeId, 1);

    console.log(`🚀 Minting badge... TX Hash: ${tx.hash}`);
    await tx.wait();
    console.log("✅ Badge minted successfully");
  } catch (error) {
    console.error("❌ Minting failed:", error);

    if (error.code === "CALL_EXCEPTION") {
      console.error("⚠️ Likely reasons: access control (e.g., onlyOwner), logic revert, or invalid badge ID.");
    }

    if (error.shortMessage) {
      console.error("💬 Error message:", error.shortMessage);
    }

    if (error.data) {
      console.error("📦 Revert data (if any):", error.data);
    }
  }
}

// Example usage: node mintBadge.js 0xRecipient 1
if (require.main === module) {
  const [,, to, badgeId] = process.argv;
  if (!to || !badgeId) {
    console.error("Usage: node mintBadge.js <recipient_address> <badge_id>");
    process.exit(1);
  }
  mintBadge(to, parseInt(badgeId));
}
