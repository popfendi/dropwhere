import { useState } from "react";
import "./App.css";
import Compass from "./components/Compass";
import { BlueCreateWalletButton } from "./components/CreateWalletButton";

const displays = ["proximity", "type", "symbol"];

function App() {
  const [display, setDisplay] = useState(0);

  const handleClick = () => {
    var currentDisplay = display;
    var i = currentDisplay >= displays.length - 1 ? 0 : currentDisplay + 1;
    setDisplay(i);
  };

  return (
    <div className="App">
      <div className="nav-buttons">
        <BlueCreateWalletButton />
      </div>
      <button className="info-button" onClick={handleClick}>
        i
      </button>
      <div className="overlay"></div>
      <Compass display={displays[display]} />
    </div>
  );
}

export default App;
