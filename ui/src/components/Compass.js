import React from "react";
import { useEffect, useState } from "react";
import useGeolocation from "../hooks/useGeolocation";
import MessageRenderer from "./MessageRenderer";
import { useAccount } from "wagmi";
import { writeContract } from "@wagmi/core";
import { wagmiConfig } from "../WagmiConfig";
import { dropManagerABI } from "../abi/dropManager";
import { useAlert } from "react-alert";
import { config } from "../config";
import { spiral } from "ldrs";
import { isIOS } from "react-device-detect";

spiral.register();

const Compass = (props) => {
  const [alpha, setAlpha] = useState(0);
  const [dir, setDir] = useState("");
  const { position, error } = useGeolocation();
  const [deltas, setDeltas] = useState([]);
  const [veryCloseDeltas, setVeryCloseDeltas] = useState([]);
  const [isClose, setIsClose] = useState(false);
  const [loading, setLoading] = useState(false);
  const [iphonePermission, setIphonePermission] = useState(null);

  const alert = useAlert();
  const account = useAccount();

  useEffect(() => {
    //implimentation yoinked from: https://onlinecompass.app/ <-cheers m8

    const requestPermission = async () => {
      try {
        if (
          typeof DeviceOrientationEvent.requestPermission === "function" &&
          navigator.userAgent.includes("iPhone")
        ) {
          await DeviceOrientationEvent.requestPermission().then((response) => {
            if (response === "granted") {
              window.addEventListener("deviceorientation", manageCompass);
            } else {
              alert("Permission denied for accessing device orientation");
            }
          });
        } else {
          window.addEventListener("deviceorientation", manageCompass);
        }
      } catch (error) {
        alert("Error while requesting device orientation permission", error);
      }
      setIphonePermission(null);
    };

    // Manage compass data
    function manageCompass(event) {
      let absoluteHeading;
      if (event.webkitCompassHeading) {
        absoluteHeading = event.webkitCompassHeading - 180;
      } else {
        absoluteHeading = 180 + event.alpha;
      }
      absoluteHeading = (absoluteHeading - 180) % 360;
      if (absoluteHeading > 360) {
        absoluteHeading -= 360;
      }

      if (isIOS) {
        absoluteHeading = -absoluteHeading;
      }

      setAlpha(absoluteHeading);
      setDir(disha(absoluteHeading));
    }

    // Determine the cardinal direction based on the angle
    function disha(angle) {
      if (angle >= 22.5 && angle < 67.5) return "NW";
      if (angle >= 67.5 && angle < 112.5) return "W";
      if (angle >= 112.5 && angle < 157.5) return "SW";
      if (angle >= 157.5 && angle < 202.5) return "S";
      if (angle >= 202.5 && angle < 247.5) return "SE";
      if (angle >= 247.5 && angle < 292.5) return "E";
      if (angle >= 292.5 && angle < 337.5) return "NE";
      return "N";
    }

    // Add event listener based on device type
    if (isIOS) {
      setIphonePermission(
        <>
          <button
            style={{
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
              zIndex: 99999,
            }}
            onClick={requestPermission}
          >
            start
          </button>
        </>,
      );
    } else {
      window.addEventListener("deviceorientationabsolute", manageCompass, true);
    }

    // Register service worker if supported
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker
        .register("/service-worker.js", { scope: "." })
        .then(function (registration) {
          console.log(
            "Service Worker registered with scope:",
            registration.scope,
          );
        })
        .catch(function (error) {
          console.error("Service Worker registration failed:", error);
        });
    }
  }, []);

  useEffect(() => {
    const fetchDeltas = async () => {
      if (position.latitude && position.longitude) {
        //alert.show("making request");
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
          if (data == null || data == undefined) {
            setDeltas([]);
            return;
          }
          setDeltas(data);
        } catch (error) {
          console.error("Error fetching deltas:", error);
        }
      }
    };

    const intervalId = setInterval(fetchDeltas, 2500);

    return () => clearInterval(intervalId);
  }, [position.latitude, position.longitude]);

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
      filter: `drop-shadow(0px 0px 4px ${obj.color})`,
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
      filter: `drop-shadow(0px 0px 4px rgba(61, 59, 89, 0.8))`,
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
      } else {
        let drop = veryCloseDeltas[0];
        handleUnlockDrop(
          drop["id"],
          drop["password"],
          drop["hashedPassword"],
          drop["sender"],
        );
      }
    } else {
      return;
    }
  };

  const handleUnlockDrop = async (lockId, pw, pwHash, locker) => {
    const userAddress = await account.address;

    if (userAddress == null || userAddress == undefined) {
      alert.show("Can't get your address, create a SmartWallet first!", {
        type: "error",
      });
      return;
    }

    try {
      setLoading(true);
      const proofRes = await fetch(`${config.proofURL}${config.proofPath}`, {
        timeout: 120000,
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          passwordHex: pw,
          lockerAddressHex: locker,
          unlockerAddressHex: userAddress,
          lockHashHex: pwHash,
        }),
      });

      if (proofRes.status != 200) {
        alert.show("Error generating proof", { type: "error" });
        setLoading(false);
        return;
      }

      const data = await proofRes.json();

      const hash = await writeContract(wagmiConfig, {
        abi: dropManagerABI,
        address: config.dropManagerAddress,
        functionName: "unlockDrop",
        args: [
          [
            data["proof"][0][0],
            data["proof"][0][1],
            data["proof"][1][0][0],
            data["proof"][1][0][1],
            data["proof"][1][1][0],
            data["proof"][1][1][1],
            data["proof"][2][0],
            data["proof"][2][1],
          ],
          lockId,
        ],
      });

      alert.show(`success TX hash: ${hash}`);
      setLoading(false);
    } catch (error) {
      setLoading(false);
      console.log(error);
    }
  };

  const iconHandler = () => {
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
    } else if (
      isClose &&
      veryCloseDeltas.length > 0 &&
      veryCloseDeltas[0]["type"] == "message"
    ) {
      return <MessageRenderer indices={veryCloseDeltas[0]["text"]} />;
    } else if (
      isClose &&
      veryCloseDeltas.length > 0 &&
      veryCloseDeltas[0]["type"] != "message"
    ) {
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
    } else {
      return <>{dir}</>;
    }
  };

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
      {iphonePermission}
      {iphonePermission == null ? (
        <div className="radar-container" style={compassStyle}>
          <div className="radar-div">{mapDeltas}</div>
          {loading ? (
            <div
              style={{
                boxShadow: "inset 0 0 30px #48435C",
                borderRadius: "50%",
                minWidth: "95px",
                maxWidth: "95px",
                height: "95px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <l-spiral size="40" speed="0.9" color="white"></l-spiral>
            </div>
          ) : (
            <p
              onClick={handleRadarClick}
              style={{
                boxShadow: "inset 0 0 30px #48435C",
                color: "#48435C",
                fontSize: 15,
                fontFamily: "Times New Roman",
                minWidth: "95px",
                maxWidth: "95px",
                height: "95px",
                borderRadius: "50%",
                textAlign: "center",
                transform: `rotate(${-alpha}deg)`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              {iconHandler()}
            </p>
          )}
          <div className="pulseLoader"></div>
        </div>
      ) : null}
    </div>
  );
};

export default Compass;
