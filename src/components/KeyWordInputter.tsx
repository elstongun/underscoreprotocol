import { AlchemyProvider } from "@ethersproject/providers";
import { ethers } from "ethers";
import { chain, configureChains } from "wagmi";
import { alchemyProvider } from "wagmi/providers/alchemy";
import "../abi/ItemFactory.json";
import "../abi/ItemListing.json";
import "./ItemListingCard";
import React, { Component, useEffect, useState } from "react";
import { Goerli } from "@usedapp/core";
import { interactivity } from "@chakra-ui/react";
import { ListingCard } from "./ItemListingCard";
import { url } from "inspector";

export function KeyWordInputter() {
  const provider = new AlchemyProvider(
    "goerli",
    "9jzB567qfCjDccM7S1V2qpmv052YIhv7"
  );
  const FactoryABI = require("../abi/ItemFactory.json");
  const FactoryAddress = "0x90dEeaf862C64955b12a0100aa5b3F5C440Eea4E";
  const FactoryContract = new ethers.Contract(
    FactoryAddress,
    FactoryABI,
    provider
  );
  const [allListings, setallListings] = useState([]);
  const [keyword, setKeyword] = useState('car');
  const [urlArray, seturlArray] = useState<any[]>([]);
  const [nameArray, setnameArray] = useState<any[]>([]);
  const [sellerArray, setsellerArray] = useState<any[]>([]);
  const [priceArray, setpriceArray] = useState<any[]>([]);
  const [numOfLeftArray, setnumOfLeftArray] = useState<any[]>([]);
  const ListingABI = require("../abi/ItemListing.json");



  useEffect(() => {
    FactoryContract.GetActiveListingsByKeyword(`${keyword}`)
      .then((listingData: React.SetStateAction<never[]>) =>
        setallListings(listingData)
      );
    setallListings(allListings);
  }, [keyword]);
  


  useEffect(() => {
    const updateListings = async () => {
      const ListingABI = require("../abi/ItemListing.json");
      const totalListings = allListings.length;
      const listingData = [];
      for (let tokenIndex = 0; tokenIndex < totalListings; tokenIndex++) {
        try {
          const ItemContract = new ethers.Contract(
            allListings[tokenIndex],
            ListingABI,
            provider
          );
          const _url = await ItemContract.getURL();
          console.log(_url)
          const _itemname = await ItemContract.getKeyword();
          const _price = 1;
          const _seller = await ItemContract.getSeller();
          const _numOfLeft = await ItemContract.getNumOfItemsLeft();
          try {
            urlArray.push(_url);
            nameArray.push(_itemname);
            priceArray.push(_price);
            sellerArray.push(_seller);
            numOfLeftArray.push(_numOfLeft);
          } catch {
            console.log("e1");
          }
        } catch {
          console.log("e2")
        }
      }
      
      console.log();
    }
    updateListings();
  }, [keyword]);

 
  const displayListings = async () => {
    <div>
      <ol>
        <li>{}</li>
      </ol>
    </div>
  }
    
  return (
    <div>
      <h1>
        <button onClick={() => setKeyword("computer parts")}>
          computer parts
        </button>
        <button onClick={() => setKeyword("car")}>car</button>
        <button onClick={() => setKeyword("fashion")}>fashion</button>
        <button onClick={() => setKeyword("books")}>books</button>
        <button onClick={() => setKeyword("random")}>random</button>
      </h1>
      <ol>
        <li></li>
      </ol>
    </div>
  );
}
