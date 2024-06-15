import React, { useState, useEffect } from "react";
import { readContracts } from "@wagmi/core";
import { tokenABI } from "../abi/token";
import { wagmiConfig } from "../WagmiConfig";

const TokenDrop = ({ onContractDetailsChanged }) => {
  const [contractAddress, setContractAddress] = useState("");
  const [contractName, setContractName] = useState("");
  const [contractSymbol, setContractSymbol] = useState("");
  const [amount, setAmount] = useState("");
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
        abi: tokenABI,
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
    setAmount(a);
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
      amount,
      expiryDate,
      loading,
      type: "erc20",
    });
  }, [
    contractAddress,
    amount,
    expiryDate,
    contractName,
    contractSymbol,
    loading,
  ]);

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
        Amount:
        <input
          type="number"
          value={amount}
          onChange={handleAmountChange}
          placeholder="Enter amount"
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

export default TokenDrop;
