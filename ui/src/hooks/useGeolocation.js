import { useState, useEffect } from "react";
import { useAlert } from "react-alert";

const useGeolocation = () => {
  const [position, setPosition] = useState({ latitude: null, longitude: null });
  const [error, setError] = useState(null);
  const alert = useAlert();
  const [useHighAccuracy, setUseHighAccuracy] = useState(true);
  const [failureCount, setFailureCount] = useState(0);

  useEffect(() => {
    if (!navigator.geolocation) {
      setError("Geolocation is not supported by your browser");
      return;
    }

    const success = (position) => {
      //alert.show(position.coords.latitude);
      setPosition({
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
      });
      setFailureCount(0);
    };

    const error = () => {
      setFailureCount((prevCount) => prevCount + 1);
      setError("Unable to retrieve your location");

      if (useHighAccuracy && failureCount >= 1) {
        setUseHighAccuracy(false);
      }
    };

    const getLocation = () => {
      const options = {
        enableHighAccuracy: useHighAccuracy,
        timeout: 5000,
        maximumAge: 2500,
      };
      navigator.geolocation.getCurrentPosition(success, error, options);
    };

    getLocation();
    const intervalId = setInterval(getLocation, 2500);

    return () => clearInterval(intervalId);
  }, [useHighAccuracy, failureCount]);

  return { position, error };
};

export default useGeolocation;
