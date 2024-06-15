import React from "react";
import { useState, useRef, useMemo } from "react";
import { MapContainer, TileLayer, Marker } from "react-leaflet";
import { useAccount, useSignMessage } from "wagmi";

import MessageBuilder from "./MessageBuilder";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import icon from "leaflet/dist/images/marker-icon.png";
import iconShadow from "leaflet/dist/images/marker-shadow.png";
import { config } from "../config";

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
  const markerRef = useRef(null);
  const { signMessage } = useSignMessage({
    mutation: {
      onSuccess: (sig) => {
        postMessage(sig);
      },
    },
  });
  const account = useAccount();

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
          alert(res.json());
          return;
        }

        handleMessagePostSuccess();
      })
      .catch(function (res) {
        console.log(res);
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
      return;
    } else if (tab == "nft") {
      return;
    } else if (tab == "eth") {
      return;
    }
  };

  const handleMessageConstructed = (indices) => {
    setMessageIndices(indices);
  };

  const handleMessageDrop = async () => {
    if (messageIndices == null || messageIndices.length == 0) {
      alert("Build a message first!");
      return;
    }

    if (position == null) {
      alert("Pick a location first!");
      return;
    }

    var message = {};
    const address = await account.address;

    if (address == null || address == undefined) {
      alert("Can't get your address, create a SmartWallet first!");
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
