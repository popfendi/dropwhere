// src/components/Compass.js
import React from "react";
import { useEffect, useState } from "react";
import useDeviceOrientation from "../hooks/useDeviceOrientation";
import useGeolocation from "../hooks/useGeolocation";

const Compass = (props) => {
  const { alpha, dir } = useDeviceOrientation();
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
              proximity: "<5km",
              symbol: "$test",
              name: "test",
              amount: 1000000000,
              type: "erc20",
            },
            {
              id: "b7816282-8639-4462-af86-a7db9cffdc53",
              direction: -11.760248531080874,
              proximity: "10km",
              symbol: "$tst",
              name: "test",
              amount: 1000000000,
              type: "erc20",
            },
            {
              id: "3",
              direction: -90.56566011365483,
              proximity: "<3km",
              symbol: "$test",
              name: "test",
              amount: 1000000000,
              type: "erc20",
            },
            {
              id: "4",
              direction: -30.760248531080874,
              proximity: "<250m",
              symbol: "$tst",
              name: "test",
              amount: 1000000000,
              type: "erc20",
            },
            {
              id: "5",
              direction: -140.56566011365483,
              proximity: "<8km",
              symbol: "$test",
              name: "test",
              amount: 1000000000,
              type: "erc20",
            },
            {
              id: "6",
              direction: -170.760248531080874,
              proximity: "<500m",
              symbol: "$tst",
              name: "test",
              amount: 1000000000,
              type: "erc20",
            },
            {
              id: "7",
              direction: -200.760248531080874,
              proximity: "<10km",
              symbol: "$tst",
              name: "test",
              amount: 1000000000,
              type: "erc20",
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
        proximity: "<5km",
        symbol: "$test",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
      {
        id: "b7816282-8639-4462-af86-a7db9cffdc53",
        direction: -11.760248531080874,
        proximity: "10km",
        symbol: "$tst",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
      {
        id: "3",
        direction: -90.56566011365483,
        proximity: "<3km",
        symbol: "$test",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
      {
        id: "4",
        direction: -30.760248531080874,
        proximity: "<250m",
        symbol: "$tst",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
      {
        id: "5",
        direction: -140.56566011365483,
        proximity: "<8km",
        symbol: "$test",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
      {
        id: "6",
        direction: -170.760248531080874,
        proximity: "<500m",
        symbol: "$tst",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
      {
        id: "7",
        direction: -200.760248531080874,
        proximity: "<10km",
        symbol: "$tst",
        name: "test",
        amount: 1000000000,
        type: "erc20",
      },
    ]);
  }, []);

  const compassStyle = {
    transform: `rotate(${alpha}deg)`,
    height: "90px",
    width: "90px",
    border: "3px solid #9792E3",
    backgroundColor: "#9792E3",
    margin: 0,
    padding: 0,
    borderRadius: "50%",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "24px",
    fontWeight: "bold",
  };

  const getPrizeStyleData = (delta) => {
    var obj = {};
    switch (delta.proximity) {
      case "<250m":
        obj.size = 50;
        obj.color = "#61E786";
        obj.offset = "90";
        break;
      case "<500m":
        obj.size = 40;
        obj.color = "#61E786";
        obj.offset = "95";
        break;
      case "<1km":
        obj.size = 40;
        obj.color = "#E6AF2E";
        obj.offset = "100";
        break;
      case "<3km":
        obj.size = 35;
        obj.color = "#E6AF2E";
        obj.offset = "100";
        break;
      case "<5km":
        obj.size = 35;
        obj.color = "#FF7D00";
        obj.offset = "115";
        break;
      case "<8km":
        obj.size = 35;
        obj.color = "#FF7D00";
        obj.offset = "155";
        break;
      case "<10km":
        obj.size = 30;
        obj.color = "#BD1E1E";
        obj.offset = "175";
        break;
      case "10km":
        obj.size = 25;
        obj.color = "#BD1E1E";
        obj.offset = "181";
        break;
    }
    return obj;
  };

  const prizeStyle = (delta) => {
    var obj = getPrizeStyleData(delta);
    return {
      position: "absolute",
      top: "50%",
      left: "50%",
      borderRadius: "50%",
      width: obj.size,
      height: obj.size,
      padding: 10,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      transform: `rotate(${delta.direction}deg) translate(0, -${obj.offset}px) rotate(${-delta.direction}deg)`, // Adjust the position to the edge
      transformOrigin: "center center",
      backgroundColor: obj.color,
    };
  };

  const prizeTextStyle = (direction) => ({
    transform: `rotate(${direction}deg)`,
    fontSize: 10,
  });

  /*
  if (error) {
    alert(error);
  }
*/
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
        height: "95vh",
      }}
    >
      <div className="radar-container" style={compassStyle}>
        <div className="radar-div">
          {deltas.map((delta) => (
            <div
              className="radar-icon"
              key={delta.id}
              style={prizeStyle(delta)}
            >
              <div style={prizeTextStyle(delta.direction)}>
                {delta[props.display]}
              </div>
            </div>
          ))}
        </div>
        <p
          style={{
            color: "#48435C",
            fontSize: 15,
            fontFamily: "Times New Roman",
            minWidth: "30px",
            maxWidth: "30px",
            textAlign: "center",
            transform: `rotate(${-alpha}deg)`,
          }}
        >
          {dir}
        </p>
        <div className="pulseLoader"></div>
      </div>
    </div>
  );
};

export default Compass;
