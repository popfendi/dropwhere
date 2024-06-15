import { useState } from "react";
import "./App.css";
import Compass from "./components/Compass";
import { BlueCreateWalletButton } from "./components/CreateWalletButton";
import { transitions, positions, Provider as AlertProvider } from "react-alert";
import AlertTemplate from "react-alert-template-basic";
import Create from "./components/Create";
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { wagmiConfig } from "./WagmiConfig";

const displays = ["proximity", "type", "symbol"];

const queryClient = new QueryClient();

const alertOptions = {
  position: positions.BOTTOM_CENTER,
  timeout: 3000,
  offset: "30px",
  transition: transitions.SCALE,
};

function App() {
  const [display, setDisplay] = useState(0);
  const [page, setPage] = useState("radar");

  const handleClick = () => {
    var currentDisplay = display;
    var i = currentDisplay >= displays.length - 1 ? 0 : currentDisplay + 1;
    setDisplay(i);
  };

  const togglePage = () => {
    var current = page;
    if (current == "radar") {
      setPage("create");
    } else if (current == "create") {
      setPage("radar");
    }
  };

  return (
    <AlertProvider template={AlertTemplate} {...alertOptions}>
      <WagmiProvider config={wagmiConfig}>
        <QueryClientProvider client={queryClient}>
          <div className="App">
            <div className="nav-buttons">
              <BlueCreateWalletButton />
              <button className="button-style" onClick={togglePage}>
                {page == "radar" ? "Create" : "Radar"}
              </button>
            </div>
            <button
              className="info-button"
              onClick={handleClick}
              style={{ display: page == "radar" ? "inherit" : "none" }}
            >
              i
            </button>
            <div
              className="overlay"
              style={{ display: page == "radar" ? "inherit" : "none" }}
            ></div>
            {page == "radar" ? (
              <Compass display={displays[display]} />
            ) : (
              <Create />
            )}
          </div>
        </QueryClientProvider>
      </WagmiProvider>
    </AlertProvider>
  );
}

export default App;
