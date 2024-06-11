import React from "react";
import { useState, useRef, useMemo } from "react";
import { MapContainer, TileLayer, Marker } from "react-leaflet";
import MessageBuilder from "./MessageBuilder";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import icon from "leaflet/dist/images/marker-icon.png";
import iconShadow from "leaflet/dist/images/marker-shadow.png";

const center = {
  lat: 51.505,
  lng: -0.09,
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
  const markerRef = useRef(null);

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

  const handleMessageDrop = () => {
    //handle message logic
  };

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "flex-start",
        alignItems: "center",
        height: "95vh",
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
