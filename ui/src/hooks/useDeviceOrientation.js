// src/hooks/useDeviceOrientation.js
import { useState, useEffect } from "react";

const useDeviceOrientation = () => {
  const [orientation, setOrientation] = useState(0);
  const [direction, setDirection] = useState("");

  useEffect(() => {
    //implimentation yoinked from: https://onlinecompass.app/ <-cheers m8
    // Check if the device is an iOS device
    function isiOS() {
      return (
        [
          "iPad Simulator",
          "iPhone Simulator",
          "iPod Simulator",
          "iPad",
          "iPhone",
          "iPod",
        ].includes(navigator.platform) ||
        (navigator.userAgent.includes("Mac") && "ontouchend" in document)
      );
    }

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
      setOrientation(absoluteHeading);
      setDirection(disha(absoluteHeading));
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
    if (isiOS()) {
      window.addEventListener("deviceorientation", manageCompass);
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

  return { alpha: orientation, dir: direction };
};

export default useDeviceOrientation;
