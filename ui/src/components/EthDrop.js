import React, { useState, useEffect } from "react";

const EthDrop = ({ onContractDetailsChanged }) => {
  const [amount, setAmount] = useState("");
  const [expiryDate, setExpiryDate] = useState("");

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
      contractAddress: null,
      contractName: null,
      contractSymbol: null,
      amount,
      expiryDate,
      loading: null,
      type: "eth",
    });
  }, [amount, expiryDate]);

  return (
    <div className="contract-form-container">
      <p>Enter Details</p>
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

export default EthDrop;
