// src/hooks/useGeolocation.js
import { useState, useEffect } from "react";

const useGeolocation = () => {
  const [position, setPosition] = useState({ latitude: null, longitude: null });
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!navigator.geolocation) {
      setError("Geolocation is not supported by your browser");
      return;
    }

    const success = (position) => {
      setPosition({
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
      });
    };

    const error = () => {
      setError("Unable to retrieve your location");
    };

    const options = {
      enableHighAccuracy: true,
      timeout: 5000,
      maximumAge: 0,
    };

    const watchId = navigator.geolocation.watchPosition(
      success,
      error,
      options,
    );

    return () => navigator.geolocation.clearWatch(watchId);
  }, []);

  return { position, error };
};

export default useGeolocation;
