// server.js
const express = require("express");
const bodyParser = require("body-parser");
const { ethers } = require("ethers");
require("dotenv").config();

const ABI = [
  {
    inputs: [
      { internalType: "address", name: "to", type: "address" },
      { internalType: "uint256", name: "badgeId", type: "uint256" },
      { internalType: "uint256", name: "amount", type: "uint256" }
    ],
    name: "mintBadge",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function"
  }
];

const app = express();
app.use(bodyParser.json());

const provider = new ethers.JsonRpcProvider(process.env.BASE_RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const contract = new ethers.Contract(process.env.BADGE_CONTRACT_ADDRESS, ABI, wallet);

// Health Check
app.get("/", (req, res) => {
  res.send("🎖️ Achievement Badge API is running");
});

// POST /mint
app.post("/mint", async (req, res) => {
  const { to, badgeId, amount = 1 } = req.body;

  if (!ethers.isAddress(to) || badgeId === undefined) {
    return res.status(400).json({ error: "Invalid or missing 'to' or 'badgeId'" });
  }

  console.log("📥 Mint Request:", { to, badgeId, amount });

  try {
    const code = await provider.getCode(contract.target || contract.address);
    console.log("🔍 Contract code check:", code);

    if (code === "0x") {
      return res.status(500).json({ error: "No contract deployed at the given address." });
    }

    const tx = await contract.mintBadge(to, badgeId, amount);
    console.log(`🚀 Mint TX Sent: ${tx.hash}`);

    const receipt = await tx.wait();
    console.log("✅ Minted Successfully:", receipt.transactionHash);

    return res.json({ success: true, txHash: tx.hash });
  } catch (error) {
    console.error("❌ Minting Failed:", error);
    return res.status(500).json({
      error: error.shortMessage || error.message || "Transaction failed",
      details: error
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
