import "./App.css";
import Compass from "./components/Compass";
import { BlueCreateWalletButton } from "./components/CreateWalletButton";

function App() {
  return (
    <div className="App">
      <BlueCreateWalletButton />
      <div className="overlay"></div>
      <Compass />
    </div>
  );
}

export default App;
