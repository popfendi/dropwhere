import { useState } from "react";
import "./App.css";
import Compass from "./components/Compass";
import { BlueCreateWalletButton } from "./components/CreateWalletButton";
import Create from "./components/Create";
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { config } from "./WagmiConfig";

const displays = ["proximity", "type", "symbol"];

const queryClient = new QueryClient();

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
    <WagmiProvider config={config}>
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
  );
}

export default App;
