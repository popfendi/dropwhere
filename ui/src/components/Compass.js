import React from "react";
import { useEffect, useState } from "react";
import useDeviceOrientation from "../hooks/useDeviceOrientation";
import useGeolocation from "../hooks/useGeolocation";
import MessageRenderer from "./MessageRenderer";
import { useAlert } from "react-alert";
import { config } from "../config";

const Compass = (props) => {
  const { alpha, dir } = useDeviceOrientation();
  const { position, error } = useGeolocation();
  const [deltas, setDeltas] = useState([]);
  const [veryCloseDeltas, setVeryCloseDeltas] = useState([]);
  const [isClose, setIsClose] = useState(false);

  const alert = useAlert();

  useEffect(() => {
    const fetchDeltas = async () => {
      if (position.latitude && position.longitude) {
        try {
          const response = await fetch(
            `${config.pathfinderURL}${config.deltaPath}`,
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                latitude: position.latitude,
                longitude: position.longitude,
              }),
            },
          );

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
            {
              id: "8",
              direction: -230.760248531080874,
              proximity: "<10m",
              sender: "0x000000",
              text: [8, 0, 37],
              type: "message",
            },
          ]);
        }
      }
    };

    const intervalId = setInterval(fetchDeltas, 1000);

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
      {
        id: "8",
        direction: -230.760248531080874,
        sender: "0x000000",
        proximity: "<10m",
        text: [8, 0, 37],
        type: "message",
      },
    ]);
  }, []);

  const compassStyle = {
    transform: `rotate(${alpha}deg)`,
    height: "93px",
    width: "93px",

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
        obj.offset = 85;
        break;
      case "<500m":
        obj.size = 40;
        obj.color = "#61E786";
        obj.offset = 90;
        break;
      case "<1km":
        obj.size = 40;
        obj.color = "#E6AF2E";
        obj.offset = 95;
        break;
      case "<3km":
        obj.size = 35;
        obj.color = "#E6AF2E";
        obj.offset = 120;
        break;
      case "<5km":
        obj.size = 35;
        obj.color = "#FF7D00";
        obj.offset = 130;
        break;
      case "<8km":
        obj.size = 35;
        obj.color = "#FF7D00";
        obj.offset = 150;
        break;
      case "<10km":
        obj.size = 30;
        obj.color = "#BD1E1E";
        obj.offset = 170;
        break;
      case "10km":
        obj.size = 25;
        obj.color = "#BD1E1E";
        obj.offset = 175;
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

  const messageStyle = (delta) => {
    var obj = getPrizeStyleData(delta);
    return {
      position: "absolute",
      top: "50%",
      left: "50%",
      borderRadius: "50%",
      width: obj.size - 15,
      height: obj.size - 15,
      padding: 10,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      transform: `rotate(${delta.direction}deg) translate(0, -${obj.offset + 15}px) rotate(${-delta.direction}deg)`, // Adjust the position to the edge
      transformOrigin: "center center",
      backgroundColor: "rgba(61, 59, 89, 0.8)",
    };
  };

  const prizeTextStyle = (direction) => ({
    transform: `rotate(${direction}deg)`,
    fontSize: 10,
  });

  const messageTextStyle = (direction) => ({
    transform: `rotate(${direction}deg)`,
    fontSize: 20,
  });

  useEffect(() => {
    let close = false;
    const veryClose = [];

    deltas.forEach((delta) => {
      if (delta.proximity === "<100m") {
        close = true;
      }
      if (delta.proximity === "<10m") {
        close = true;
        veryClose.push(delta);
      }
    });

    if (close !== isClose) {
      setIsClose(close);
    }

    setVeryCloseDeltas(veryClose);
  }, [deltas]);

  const mapDeltas = deltas.map((delta) => {
    if (delta.proximity === "<100m" || delta.proximity === "<10m") {
      return null;
    } else {
      return delta.type === "message" ? (
        <div className="radar-icon" key={delta.id} style={messageStyle(delta)}>
          <div style={messageTextStyle(delta.direction)}>✉️</div>
        </div>
      ) : (
        <div className="radar-icon" key={delta.id} style={prizeStyle(delta)}>
          <div style={prizeTextStyle(delta.direction)}>
            {delta[props.display]}
          </div>
        </div>
      );
    }
  });

  const handleRadarClick = () => {
    if (isClose && veryCloseDeltas.length == 0) {
      alert.show("You're close! keep searching the area 👀");
    }
    if (isClose && veryCloseDeltas.length > 0) {
      if (veryCloseDeltas[0]["type"] == "message") {
        alert.show(`Message Left by: ${veryCloseDeltas[0]["sender"]}`);
      }
    } else {
      return;
    }
  };

  const isCloseIconHandler = () => {
    if (isClose && veryCloseDeltas.length == 0) {
      return (
        <p
          style={{
            fontFamily: '"Tiny5", sans-serif',
            textAlign: "center",
            fontSize: 50,
            padding: 0,
            margin: 0,
          }}
        >
          ❔
        </p>
      );
    }
    if (
      isClose &&
      veryCloseDeltas.length > 0 &&
      veryCloseDeltas[0]["type"] == "message"
    ) {
      return <MessageRenderer indices={veryCloseDeltas[0]["text"]} />;
    } else {
      return (
        <p
          style={{
            fontFamily: '"Tiny5", sans-serif',
            textAlign: "center",
            fontSize: 50,
            padding: 0,
            margin: 0,
          }}
        >
          ⛏️
        </p>
      );
    }
  };

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
        <div className="radar-div">{mapDeltas}</div>
        <p
          onClick={handleRadarClick}
          style={{
            color: "#48435C",
            fontSize: 15,
            fontFamily: "Times New Roman",
            minWidth: "95px",
            maxWidth: "95px",
            height: "95px",
            borderRadius: "50%",
            textAlign: "center",
            transform: `rotate(${-alpha}deg)`,
            boxShadow: "inset 0 0 30px #48435C",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {isClose ? isCloseIconHandler() : dir}
        </p>
        <div className="pulseLoader"></div>
      </div>
    </div>
  );
};

export default Compass;
