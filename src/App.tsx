import { useAccount } from 'wagmi'
import { AlchemyProvider } from "@ethersproject/providers";
import { ethers } from "ethers";
import "./abi/ItemFactory.json";
import "./abi/ItemListing.json";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { KeyWordInputter } from "./components/KeyWordInputter";
import { Account, Connect, NetworkSwitcher } from './components'
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Link,
  useParams,
} from "react-router-dom";
import { useState, useEffect } from 'react';

export function App() {
  const { isConnected } = useAccount()
  
  return (
    <Router>
      <h1>_underscore</h1>

      <Connect />

      {isConnected && (
        <>
          <Account />
          <NetworkSwitcher />
        </>
      )}
      <h1>Categories</h1>
      <>
        <KeyWordInputter />
      </>
    </Router>
  );
}
