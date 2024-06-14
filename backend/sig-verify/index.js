import express from "express";
import { createPublicClient, http } from "viem";
import { baseSepolia } from "viem/chains";

const app = express();
const port = 8008;

app.use(express.json());

const client = createPublicClient({
  chain: baseSepolia,
  transport: http(),
});

app.post("/verify", async (req, res) => {
  const { address, message, signature } = req.body;

  try {
    const valid = await client.verifyMessage({
      address,
      message,
      signature,
    });

    res.json({ success: valid });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
