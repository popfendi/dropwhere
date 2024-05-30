// src/hooks/useDeviceOrientation.js
import { useState, useEffect } from "react";

const useDeviceOrientation = () => {
  const [orientation, setOrientation] = useState({ alpha: 0 });

  useEffect(() => {
    const handleOrientation = (event) => {
      setOrientation({ alpha: event.alpha });
    };

    const requestPermission = async () => {
      if (typeof DeviceOrientationEvent.requestPermission === "function") {
        try {
          const permission = await DeviceOrientationEvent.requestPermission();
          if (permission === "granted") {
            window.addEventListener("deviceorientation", handleOrientation);
          }
        } catch (error) {
          console.error("Permission denied", error);
        }
      } else {
        // For browsers that don't require explicit permission
        window.addEventListener("deviceorientation", handleOrientation);
      }
    };

    requestPermission();

    return () =>
      window.removeEventListener("deviceorientation", handleOrientation);
  }, []);

  return orientation;
};

export default useDeviceOrientation;
