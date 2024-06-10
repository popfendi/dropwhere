import React, { useCallback, useState } from "react";
import { CoinbaseWalletSDK } from "@coinbase/wallet-sdk";
import { CoinbaseWalletLogo } from "./CoinbaseWalletLogo";

const buttonStyles = {
  background: "transparent",
  border: "1px solid transparent",
  boxSizing: "border-box",
  display: "flex",
  alignItems: "center",
  justifyContent: "space-between",
  width: 200,
  fontFamily: "Arial, sans-serif",
  fontWeight: "bold",
  fontSize: 18,
  backgroundColor: "#9792E3",
  paddingLeft: 15,
  paddingRight: 30,
  borderRadius: 10,
  cursor: "pointer",
};

const sdk = new CoinbaseWalletSDK({
  appName: "dropwhere",
  appLogoUrl: "https://i.ibb.co/pxCGggP/dwlogo.png",
  appChainIds: [84532],
});

const provider = sdk.makeWeb3Provider();

const formatAddress = (address) => {
  return address.slice(0, 10).concat("...");
};

export function BlueCreateWalletButton({ handleSuccess, handleError }) {
  const [buttonText, setButtonText] = useState("Create Wallet");
  const createWallet = useCallback(async () => {
    try {
      const [address] = await provider.request({
        method: "eth_requestAccounts",
      });
      setButtonText(formatAddress(address));
    } catch (error) {
      alert(error);
    }
  }, [handleSuccess, handleError]);

  return (
    <button style={buttonStyles} onClick={createWallet}>
      <CoinbaseWalletLogo />
      {buttonText}
    </button>
  );
}
