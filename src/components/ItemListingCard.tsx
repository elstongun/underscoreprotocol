import "../abi/ItemListing.json";
import { useEffect, useState } from "react";
import { AlchemyProvider } from "@ethersproject/providers";
import { ethers } from "ethers";
import Card from "@mui/material/Card";
import CardActions from "@mui/material/CardActions";
import CardContent from "@mui/material/CardContent";
import CardMedia from "@mui/material/CardMedia";
import Button from "@mui/material/Button";
import Typography from "@mui/material/Typography";

export const ListingCard = ({ listingAddress }: { listingAddress: any }) => {
  const ListingABI = require("../abi/ItemListing.json");
  const [url, setURL] = useState("");
  const [itemname, setitemName] = useState("");
  const [price, setPrice] = useState(1);
  const [seller, setSeller] = useState("");
  const [numOfLeft, setnumOfLeft] = useState(0);
  const provider = new AlchemyProvider(
    "goerli",
    "9jzB567qfCjDccM7S1V2qpmv052YIhv7"
  );

    return (
    <Card sx={{ maxWidth: 345 }}>
      <CardMedia
        component="img"
        height="140"
        image={url}
        alt="name"
      />
      <CardContent>
        <Typography gutterBottom variant="h5" component="div">
          {itemname}: {price}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          NumOfLeft = {numOfLeft}
        </Typography>
      </CardContent>
      <CardActions>
        <Button size="small">Learn More</Button>
      </CardActions>
    </Card>
  );
};
