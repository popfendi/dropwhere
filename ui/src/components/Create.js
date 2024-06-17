import React from "react";
import { useState, useRef, useMemo } from "react";
import { MapContainer, TileLayer, Marker } from "react-leaflet";
import { useAccount, useSignMessage } from "wagmi";
import { readContracts, writeContract } from "@wagmi/core";
import { wagmiConfig } from "../WagmiConfig";
import { toHex, encodePacked, keccak256, parseUnits } from "viem";
import { useAlert } from "react-alert";
import { config } from "../config";
import { dropManagerABI } from "../abi/dropManager";
import { v4 } from "uuid";

import MessageBuilder from "./MessageBuilder";
import TokenDrop from "./TokenDrop";
import NftDrop from "./NftDrop";
import EthDrop from "./EthDrop";

import L from "leaflet";
import "leaflet/dist/leaflet.css";
import icon from "leaflet/dist/images/marker-icon.png";
import iconShadow from "leaflet/dist/images/marker-shadow.png";
import { tokenABI } from "../abi/token";
import { nftABI } from "../abi/nft";

const center = {
  lat: 51.505123,
  lng: -0.091231,
};

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
});

L.Marker.prototype.options.icon = DefaultIcon;

const Create = () => {
  const [position, setPosition] = useState(center);
  const [tab, setTab] = useState("message");
  const [messageIndices, setMessageIndices] = useState([0, 0, 0]);
  const [msg, setMsg] = useState({});
  const [dropDetails, setDropDetails] = useState({});
  const [dropType, setDropType] = useState("");
  const [dataIsFetching, setDataIsFetching] = useState(false);

  const markerRef = useRef(null);
  const { signMessage } = useSignMessage({
    mutation: {
      onSuccess: (sig) => {
        postMessage(sig);
      },
    },
  });
  const account = useAccount();
  const alert = useAlert();

  // handler for the movable marker on map.
  const eventHandlers = useMemo(
    () => ({
      dragend() {
        const marker = markerRef.current;
        if (marker != null) {
          setPosition(marker.getLatLng());
        }
      },
    }),
    [],
  );

  const postMessage = async (sig) => {
    await fetch(`${config.pathfinderURL}${config.messagePath}`, {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      method: "POST",
      body: JSON.stringify({ message: msg, signature: sig }),
    })
      .then(function (res) {
        if (!res.ok) {
          alert.show("error dropping message", { type: "error" });
          console.log(res);
          return;
        }

        alert.show("Message Dropped!", { type: "success" });
      })
      .catch(function (res) {
        console.log(res);
        alert.show("server error", { type: "error" });
      });
  };

  const handleTab = () => {
    if (tab == "message") {
      return (
        <>
          <MessageBuilder onMessageConstructed={handleMessageConstructed} />
          <button
            style={{ margin: 20 }}
            className="button-style"
            onClick={handleMessageDrop}
          >
            Drop Message
          </button>
        </>
      );
    } else if (tab == "token") {
      return (
        <>
          <TokenDrop onContractDetailsChanged={handleContractDetails} />
          <button
            style={{ margin: 20 }}
            className="button-style"
            onClick={handleTokenDrop}
          >
            Drop Tokens
          </button>
        </>
      );
    } else if (tab == "nft") {
      return (
        <>
          <NftDrop onContractDetailsChanged={handleContractDetails} />
          <button
            style={{ margin: 20 }}
            className="button-style"
            onClick={handleNftDrop}
          >
            Drop NFT
          </button>
        </>
      );
    } else if (tab == "eth") {
      return (
        <>
          <EthDrop onContractDetailsChanged={handleContractDetails} />
          <button
            style={{ margin: 20 }}
            className="button-style"
            onClick={handleEthDrop}
          >
            Drop ETH
          </button>
        </>
      );
    }
  };

  const handleContractDetails = ({
    contractAddress,
    contractName,
    contractSymbol,
    amount,
    expiryDate,
    loading,
    type,
  }) => {
    setDropDetails({
      contractAddress,
      contractName,
      contractSymbol,
      amount,
      expiryDate,
    });
    setDropType(type);
    setDataIsFetching(loading);
  };

  const handleMessageConstructed = (indices) => {
    setMessageIndices(indices);
  };

  const handleMessageDrop = async () => {
    if (messageIndices == null || messageIndices.length == 0) {
      alert.show("Build a message first!", { type: "error" });
      return;
    }

    if (position == null) {
      alert.show("Pick a location first!", { type: "error" });
      return;
    }

    var message = {};
    const address = await account.address;

    if (address == null || address == undefined) {
      alert.show("Can't get your address, create a SmartWallet first!", {
        type: "error",
      });
      return;
    }

    message["sender"] = address;
    message["text"] = messageIndices;
    message["longitude"] = position.lng;
    message["latitude"] = position.lat;

    setMsg(message);
    let msgToSign = `${address}${message["latitude"].toFixed(3)}${message["longitude"].toFixed(3)}`; // PoC implimentation, will replace with unique UUID or Nonce
    signMessage({ message: msgToSign });
  };

  const handleTokenDrop = async () => {
    const userAddress = await account.address;

    if (userAddress == null || userAddress == undefined) {
      alert.show("Can't get your address, create a SmartWallet first!", {
        type: "error",
      });
      return;
    }

    if (
      dropDetails.contractAddress == null ||
      dropDetails.contractAddress == undefined ||
      dropDetails.contractAddress == ""
    ) {
      alert.show("Invalid Contract Address", { type: "error" });
      return;
    }

    if (
      dropDetails.contractName == null ||
      dropDetails.contractName == undefined ||
      dropDetails.contractName == ""
    ) {
      alert.show("Invalid Contract Name", { type: "error" });
      return;
    }

    if (
      dropDetails.contractSymbol == null ||
      dropDetails.contractSymbol == undefined ||
      dropDetails.contractSymbol == ""
    ) {
      alert.show("Invalid Contract Symbol", { type: "error" });
      return;
    }

    if (
      dropDetails.amount == null ||
      dropDetails.amount == undefined ||
      dropDetails.amount == 0
    ) {
      alert.show("Invalid Amount", { type: "error" });
      return;
    }

    try {
      const dropManagerContract = {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
      };

      const tokenContract = {
        abi: tokenABI,
        address: dropDetails.contractAddress,
      };
      const results = await readContracts(wagmiConfig, {
        contracts: [
          {
            ...dropManagerContract,
            functionName: "userNonces",
            args: [userAddress],
          },
          {
            ...tokenContract,
            functionName: "decimals",
          },
          {
            ...tokenContract,
            functionName: "allowance",
            args: [userAddress, config.dropManagerAddress],
          },
        ],
      });

      const userNonce = results[0]["result"];
      const decimals = results[1]["result"];
      const allowance = results[2]["result"];
      const fAmount = parseUnits(dropDetails.amount, decimals);
      const fDate = +Date.parse(dropDetails.expiryDate);

      const dropID = keccak256(
        encodePacked(["address", "uint256"], [userAddress, userNonce]),
      );

      const uuid = v4();
      const pw = keccak256(toHex(uuid)); // not the hashed pw, just to ensure always bytes32
      const hashedPw = keccak256(
        encodePacked(["address", "bytes32"], [userAddress, pw]),
      );

      const apiRes = await fetch(`${config.pathfinderURL}${config.dropPath}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          id: dropID,
          sender: userAddress,
          latitude: position.lat,
          longitude: position.lng,
          password: pw,
          hashedPassword: hashedPw,
          type: dropType,
          contractAddress: dropDetails.contractAddress,
          name: dropDetails.contractName,
          symbol: dropDetails.contractSymbol,
          amount: dropDetails.amount,
          expires: fDate,
          active: false,
        }),
      });

      if (apiRes.status != 201) {
        const data = await apiRes.json();
        alert.show(data, { type: "error" });
        return;
      }

      if (fAmount > allowance) {
        await writeContract(wagmiConfig, {
          abi: tokenABI,
          address: dropDetails.contractAddress,
          functionName: "approve",
          args: [config.dropManagerAddress, fAmount],
        });
      }

      const hash = await writeContract(wagmiConfig, {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
        functionName: "createDropLockERC20",
        args: [hashedPw, dropDetails.contractAddress, fAmount, fDate],
      });

      alert.show(`success TX hash: ${hash}`);
    } catch (error) {
      console.log(error);
    }
  };

  const handleNftDrop = async () => {
    const userAddress = await account.address;

    if (userAddress == null || userAddress == undefined) {
      alert.show("Can't get your address, create a SmartWallet first!", {
        type: "error",
      });
      return;
    }

    if (
      dropDetails.contractAddress == null ||
      dropDetails.contractAddress == undefined ||
      dropDetails.contractAddress == ""
    ) {
      alert.show("Invalid Contract Address", { type: "error" });
      return;
    }

    if (
      dropDetails.contractName == null ||
      dropDetails.contractName == undefined ||
      dropDetails.contractName == ""
    ) {
      alert.show("Invalid Contract Name", { type: "error" });
      return;
    }

    if (
      dropDetails.contractSymbol == null ||
      dropDetails.contractSymbol == undefined ||
      dropDetails.contractSymbol == ""
    ) {
      alert.show("Invalid Contract Symbol", { type: "error" });
      return;
    }

    if (dropDetails.amount == null || dropDetails.amount == undefined) {
      alert.show("Invalid ID", { type: "error" });
      return;
    }

    try {
      const dropManagerContract = {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
      };

      const tokenContract = {
        abi: nftABI,
        address: dropDetails.contractAddress,
      };
      const results = await readContracts(wagmiConfig, {
        contracts: [
          {
            ...dropManagerContract,
            functionName: "userNonces",
            args: [userAddress],
          },
          {
            ...tokenContract,
            functionName: "getApproved",
            args: [dropDetails.amount], // amount == tokenId in this context
          },
        ],
      });

      const userNonce = results[0]["result"];
      const approved = results[1]["result"] == config.dropManagerAddress;
      const fDate = +Date.parse(dropDetails.expiryDate);

      const dropID = keccak256(
        encodePacked(["address", "uint256"], [userAddress, userNonce]),
      );

      const uuid = v4();
      const pw = keccak256(toHex(uuid)); // not the hashed pw, just to ensure always bytes32
      const hashedPw = keccak256(
        encodePacked(["address", "bytes32"], [userAddress, pw]),
      );

      const apiRes = await fetch(`${config.pathfinderURL}${config.dropPath}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          id: dropID,
          sender: userAddress,
          latitude: position.lat,
          longitude: position.lng,
          password: pw,
          hashedPassword: hashedPw,
          type: dropType,
          contractAddress: dropDetails.contractAddress,
          name: dropDetails.contractName,
          symbol: dropDetails.contractSymbol,
          amount: dropDetails.amount,
          expires: fDate,
          active: false,
        }),
      });

      if (apiRes.status != 201) {
        const data = await apiRes.json();
        alert.show(data, { type: "error" });
        return;
      }

      if (!approved) {
        await writeContract(wagmiConfig, {
          abi: nftABI,
          address: dropDetails.contractAddress,
          functionName: "approve",
          args: [config.dropManagerAddress, dropDetails.amount],
        });
      }

      const hash = await writeContract(wagmiConfig, {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
        functionName: "createDropLockERC721",
        args: [
          hashedPw,
          dropDetails.contractAddress,
          dropDetails.amount,
          fDate,
        ],
      });

      alert.show(`success TX hash: ${hash}`);
    } catch (error) {
      console.log(error);
    }
  };

  const handleEthDrop = async () => {
    /*
    FLOW:
    check formatting of inputs
    get user nonce
    hash user&nonce to get ID
    generate PW
    hash PW

    post to API (active=false)
    ensure successful response

    send add drop TX

    will be activated on back end.
    */
    const userAddress = await account.address;

    if (userAddress == null || userAddress == undefined) {
      alert.show("Can't get your address, create a SmartWallet first!", {
        type: "error",
      });
      return;
    }

    if (
      dropDetails.amount == null ||
      dropDetails.amount == undefined ||
      dropDetails.amount == 0
    ) {
      alert.show("Invalid Amount", { type: "error" });
      return;
    }

    try {
      const dropManagerContract = {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
      };

      const results = await readContracts(wagmiConfig, {
        contracts: [
          {
            ...dropManagerContract,
            functionName: "userNonces",
            args: [userAddress],
          },
        ],
      });

      const userNonce = results[0]["result"];
      const fAmount = parseUnits(dropDetails.amount, 18);
      const fDate = +Date.parse(dropDetails.expiryDate);

      const dropID = keccak256(
        encodePacked(["address", "uint256"], [userAddress, userNonce]),
      );

      const uuid = v4();
      const pw = keccak256(toHex(uuid)); // not the hashed pw, just to ensure always bytes32
      const hashedPw = keccak256(
        encodePacked(["address", "bytes32"], [userAddress, pw]),
      );

      const apiRes = await fetch(`${config.pathfinderURL}${config.dropPath}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          id: dropID,
          sender: userAddress,
          latitude: position.lat,
          longitude: position.lng,
          password: pw,
          hashedPassword: hashedPw,
          type: dropType,
          contractAddress: "ETH",
          name: "Ethereum",
          symbol: "ETH",
          amount: fAmount.toString(),
          expires: fDate,
          active: false,
        }),
      });

      if (apiRes.status != 201) {
        const data = await apiRes.json();
        alert.show(data, { type: "error" });
        return;
      }

      const hash = await writeContract(wagmiConfig, {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
        functionName: "createDropLockETH",
        args: [hashedPw, fDate],
        value: fAmount,
      });

      alert.show(`success TX hash: ${hash}`);
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "flex-start",
        alignItems: "center",
        height: "95vh",
        overflowX: "scroll",
      }}
    >
      <p className="form-text">Pick a Location</p>
      <div style={{}} id="map">
        <MapContainer center={center} zoom={13} scrollWheelZoom={true}>
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <Marker
            draggable={true}
            eventHandlers={eventHandlers}
            position={position}
            ref={markerRef}
          ></Marker>
        </MapContainer>
      </div>
      <div className="drop-selector">
        <button
          className={tab == "message" ? "active-drop" : null}
          onClick={() => setTab("message")}
        >
          Message
        </button>
        <button
          className={tab == "token" ? "active-drop" : null}
          onClick={() => setTab("token")}
        >
          Token
        </button>
        <button
          className={tab == "nft" ? "active-drop" : null}
          onClick={() => setTab("nft")}
        >
          NFT
        </button>
        <button
          className={tab == "eth" ? "active-drop" : null}
          onClick={() => setTab("eth")}
        >
          ETH
        </button>
      </div>
      {handleTab()}
    </div>
  );
};

export default Create;
