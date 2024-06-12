import { initialize } from "zokrates-js";
import express from "express";
import bodyParser from "body-parser";

const app = express();
app.use(bodyParser.json());

let zokratesProvider;
let artifacts;
let keypair;

function hexStringToByteArray(hexString) {
  if (hexString.startsWith("0x")) {
    hexString = hexString.slice(2);
  }
  if (hexString.length % 2 !== 0) {
    hexString = "0" + hexString;
  }
  const byteArray = [];
  for (let i = 0; i < hexString.length; i += 2) {
    byteArray.push(String(parseInt(hexString.substr(i, 2), 16)));
  }
  return byteArray;
}

function buildInputs(
  passwordHex,
  lockerAddressHex,
  unlockerAddressHex,
  lockHashHex,
) {
  const password = hexStringToByteArray(passwordHex);
  const locker = hexStringToByteArray(lockerAddressHex);
  const unlocker = hexStringToByteArray(unlockerAddressHex);
  const lockHash = hexStringToByteArray(lockHashHex);

  if (password.length !== 32) throw new Error("Password must be 32 bytes");
  if (locker.length !== 20) throw new Error("Locker address must be 20 bytes");
  if (unlocker.length !== 20)
    throw new Error("Unlocker address must be 20 bytes");
  if (lockHash.length !== 32) throw new Error("Lock hash must be 32 bytes");

  return [password, locker, unlocker, lockHash];
}

async function initializeZokrates() {
  zokratesProvider = await initialize();

  const source = `
  import "hashes/keccak/256bit" as keccak256;
  def main(private u8[32] password, u8[20] locker, u8[20] unlocker, u8[32] lockHash) {
      u8[52] f = [...password, ...locker];
      u8[32] newLockHash = keccak256(f);
      assert(lockHash == newLockHash);
      assert(unlocker != locker);
  }`;
  console.log("compiling...");
  artifacts = zokratesProvider.compile(source);
  console.log("compiled");
  console.log("setting up...");
  keypair = zokratesProvider.setup(artifacts.program);
  console.log("setup success.");
}

function ensureInitialized(req, res, next) {
  if (zokratesProvider && artifacts && keypair) {
    next();
  } else {
    res.status(503).send("Service Unavailable: Zokrates is not initialized.");
  }
}

app.post("/generate-proof", ensureInitialized, (req, res) => {
  const { passwordHex, lockerAddressHex, unlockerAddressHex, lockHashHex } =
    req.body;

  if (
    !passwordHex ||
    !lockerAddressHex ||
    !unlockerAddressHex ||
    !lockHashHex
  ) {
    return res.status(400).send("Missing required fields");
  }
  const inputs = buildInputs(
    passwordHex,
    lockerAddressHex,
    unlockerAddressHex,
    lockHashHex,
  );

  try {
    const { witness, output } = zokratesProvider.computeWitness(
      artifacts,
      inputs,
    );

    const proof = zokratesProvider.generateProof(
      artifacts.program,
      witness,
      keypair.pk,
    );
    const formattedProof = zokratesProvider.utils.formatProof(proof);

    res.json({ proof: formattedProof[0] });
  } catch {
    res.status(500).send(`{"error": "Incorrect inputs, or assertions failed"}`);
  }
});

initializeZokrates()
  .then(() => {
    app.listen(8888, () => {
      console.log("Server is running on port 8888");
    });
  })
  .catch((error) => {
    console.error("Initialization failed:", error);
  });
