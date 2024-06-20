import { useState } from "react";
import "./App.css";
import Compass from "./components/Compass";
import { BlueCreateWalletButton } from "./components/CreateWalletButton";
import { transitions, positions, Provider as AlertProvider } from "react-alert";
import AlertTemplate from "react-alert-template-basic";
import Create from "./components/Create";
import Modal from "react-modal";
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { wagmiConfig } from "./WagmiConfig";
import tg from "./tg.png";

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
  const [modalIsOpen, setIsOpen] = useState(true);

  const handleClick = () => {
    var currentDisplay = display;
    var i = currentDisplay >= displays.length - 1 ? 0 : currentDisplay + 1;
    setDisplay(i);
  };

  function closeModal() {
    setIsOpen(false);
  }

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
            <Modal
              isOpen={modalIsOpen}
              onRequestClose={closeModal}
              style={{
                content: {
                  top: "50%",
                  left: "50%",
                  right: "auto",
                  bottom: "auto",
                  marginRight: "-50%",
                  transform: "translate(-50%, -50%)",
                },
              }}
              contentLabel="info modal"
            >
              <div>
                <p>Thanks for being part of the testing phase for dropwhere!</p>
                <p>
                  This is currently in the proof of concept stage and there's a
                  few things to note:
                </p>
                <p>
                  The app will only work on mobile devices (it relies on the
                  inbuilt sensors)
                </p>
                <p>
                  We're deployed on BASE Sepolia, due to the early stages more
                  testing is needed before I can assure users are safe to lock
                  up real tokens.
                </p>
                <p>
                  As I have no way of knowing where users will be connecting
                  from. There may be no drops near you when you load in for the
                  first time. So you may need to head to the create page and add
                  them yourself!
                </p>
              </div>
              <button onClick={closeModal}>close</button>
            </Modal>
            <div
              className="overlay"
              style={{ display: page == "radar" ? "inherit" : "none" }}
            ></div>
            {page == "radar" ? (
              <Compass display={displays[display]} />
            ) : (
              <Create />
            )}
            <div className="footer">
              <a href="https://t.me/dropwhere" target="_blank">
                <img src={tg} width={75} />
              </a>
            </div>
          </div>
        </QueryClientProvider>
      </WagmiProvider>
    </AlertProvider>
  );
}

export default App;
