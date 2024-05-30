// src/components/Compass.js
import React from "react";
import { useEffect, useState } from "react";
import useDeviceOrientation from "../hooks/useDeviceOrientation";
import useGeolocation from "../hooks/useGeolocation";

const Compass = () => {
  const { alpha } = useDeviceOrientation();
  const { position, error } = useGeolocation();
  const [deltas, setDeltas] = useState([]);

  useEffect(() => {
    const fetchDeltas = async () => {
      if (position.latitude && position.longitude) {
        try {
          const response = await fetch("http://localhost:3001/delta", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              latitude: position.latitude,
              longitude: position.longitude,
            }),
          });

          const data = await response.json();
          setDeltas(data);
        } catch (error) {
          console.error("Error fetching deltas:", error);
          setDeltas([
            {
              id: "75b065e1-2f33-44c1-8be3-052b169da214",
              direction: -109.56566011365483,
              proximity: "5km",
            },
            {
              id: "b7816282-8639-4462-af86-a7db9cffdc53",
              direction: -11.760248531080874,
              proximity: "10km",
            },
          ]);
        }
      }
    };

    const intervalId = setInterval(fetchDeltas, 5000);

    return () => clearInterval(intervalId);
  }, [position.latitude, position.longitude]);

  useEffect(() => {
    setDeltas([
      {
        id: "75b065e1-2f33-44c1-8be3-052b169da214",
        direction: -109.56566011365483,
        proximity: "5km",
      },
      {
        id: "b7816282-8639-4462-af86-a7db9cffdc53",
        direction: -11.760248531080874,
        proximity: "10km",
      },
    ]);
  }, []);

  const compassStyle = {
    transform: `rotate(${alpha}deg)`,
    height: "200px",
    width: "200px",
    border: "10px solid black",
    borderRadius: "50%",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "24px",
    fontWeight: "bold",
  };

  const prizeStyle = (direction) => ({
    position: "absolute",
    top: "50%",
    left: "50%",
    transform: `rotate(${direction}deg) translate(0, -150px) rotate(${-direction}deg)`, // Adjust the position to the edge
    transformOrigin: "center center",
  });

  const prizeTextStyle = (direction) => ({
    transform: `rotate(${direction}deg)`,
  });

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
        height: "100vh",
      }}
    >
      <div style={{ rotate: "-180deg" }}>
        <div style={compassStyle}>
          <div
            style={{
              position: "absolute",
              top: "50%",
              transform: "translateY(-50%)",
            }}
          ></div>
          👆
          {deltas.map((delta) => (
            <div key={delta.id} style={prizeStyle(delta.direction)}>
              <div style={prizeTextStyle(delta.direction)}>
                {delta.proximity}
              </div>
            </div>
          ))}
        </div>
      </div>
      {error && <p>{error}</p>}
    </div>
  );
};

export default Compass;
