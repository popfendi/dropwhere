import React, { useState, useEffect } from "react";
import { readContracts } from "@wagmi/core";
import { nftABI } from "../abi/nft";
import { wagmiConfig } from "../WagmiConfig";

const NftDrop = ({ onContractDetailsChanged }) => {
  const [contractAddress, setContractAddress] = useState("");
  const [contractName, setContractName] = useState("");
  const [contractSymbol, setContractSymbol] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [expiryDate, setExpiryDate] = useState("");
  const [loading, setLoading] = useState(false);

  const useDebounce = (value, delay) => {
    const [debouncedValue, setDebouncedValue] = useState(value);

    useEffect(() => {
      const handler = setTimeout(() => {
        setDebouncedValue(value);
      }, delay);

      return () => {
        clearTimeout(handler);
      };
    }, [value, delay]);

    return debouncedValue;
  };

  const debouncedContractAddress = useDebounce(contractAddress, 1500);

  useEffect(() => {
    setLoading(true);
    fetchContractDetails();
  }, [debouncedContractAddress]);

  const fetchContractDetails = async () => {
    try {
      const tokenContract = {
        address: contractAddress,
        abi: nftABI,
      };
      const result = await readContracts(wagmiConfig, {
        contracts: [
          { ...tokenContract, functionName: "name" },
          { ...tokenContract, functionName: "symbol" },
        ],
      });
      setContractName(result[0]["result"]);
      setContractSymbol(result[1]["result"]);
      setLoading(false);
    } catch (error) {
      console.log(error);
      setLoading(false);
    }
  };

  const handleAddressChange = async (e) => {
    const address = e.target.value;
    setContractAddress(address);
  };

  const handleAmountChange = (e) => {
    let a = e.target.value;
    setTokenId(a);
  };

  const handleExpiryDateChange = (e) => {
    let date = e.target.value;
    setExpiryDate(date);
  };

  useEffect(() => {
    onContractDetailsChanged({
      contractAddress,
      contractName,
      contractSymbol,
      amount: tokenId,
      expiryDate,
      loading,
      type: "erc721",
    });
  }, [tokenId, expiryDate, contractName, contractSymbol, loading]);

  return (
    <div className="contract-form-container">
      <p>Enter Contract Details</p>
      <label>
        Contract Address:
        <input
          type="text"
          value={contractAddress}
          onChange={handleAddressChange}
          placeholder="Enter contract address"
        />
      </label>
      {contractName && contractSymbol && (
        <p>
          {contractName} ({contractSymbol})
        </p>
      )}
      <label>
        Token ID:
        <input
          type="number"
          value={tokenId}
          onChange={handleAmountChange}
          placeholder="Enter ID"
        />
      </label>
      <label>
        Expiry Date:
        <input
          type="date"
          value={expiryDate}
          onChange={handleExpiryDateChange}
        />
      </label>
    </div>
  );
};

export default NftDrop;
