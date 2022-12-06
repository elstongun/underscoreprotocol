// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./openzeppelin/Ownable.sol";
import "./openzeppelin/IERC20.sol";
import "./ItemListing.sol";

contract ItemFactory is Ownable {
    uint256 public fee = 250;
    address WETH = 0x9c3DDc0Eba8C5d16018aA678fd2B009c8268e6fc;
    mapping(address => ItemListing[]) userListings;
    mapping(address => reviewStruct[]) userRatings;
    mapping(ItemListing => bool) isListing;
    ItemListing[] allListings;
    address[] allSellers;

    event ListingCreated(string name, string symbol, string imageURL, string keyword, uint256 WETHRequested, uint256 fee);
    /** 
    listingVars
    _name = name of the item for frontend display
    _symbol = ticker for the symbol if necessary
    _imageURL = image url 
    _keyword = category keyword for search assistance
    _WETHRequested = weth wei value requested for the item
    */

    struct reviewStruct{
        uint256 rating;
        string reviewDesc;
    }

    function setFee(uint256 newFee) public onlyOwner returns (uint256) {
        fee = newFee;
        return newFee;
    }

    function createItemListing(
        string memory name,
        string memory symbol,
        string memory imageURL,
        string memory keyword,
        uint numOfItems,
        uint256 WETHRequested
        ) external returns (ItemListing) {

        require(msg.sender != owner());
        require(WETHRequested <= IERC20(WETH).totalSupply());

        ItemListing newListing = new ItemListing(msg.sender, name, symbol, imageURL, keyword, numOfItems, WETHRequested, fee);
        userListings[msg.sender].push(newListing);
        allSellers.push(msg.sender);
        allListings.push(newListing);
        isListing[newListing] = true;

        emit ListingCreated(name, symbol, imageURL, keyword, WETHRequested, fee);
        return (newListing);
    }

    function reviewSeller(ItemListing _CompletedListing, uint256 _buyerCount, uint256 rating, string memory reviewDesc) external returns (reviewStruct memory) {
        require(rating == 0 || rating == 1 || rating == 2 || rating == 3 || rating == 4 || rating == 5);
        require(_CompletedListing.isReviewed(_buyerCount) == false);
        require(_CompletedListing.getIndividualBuyer(_buyerCount) == msg.sender, "Only the buyer can review a seller");
        require(_CompletedListing.getFactory() == address(this));
        require(isListing[_CompletedListing] == true);
        
        address seller = _CompletedListing.getSeller();
        reviewStruct memory vars;
        vars.rating = rating;
        vars.reviewDesc = reviewDesc;
        _CompletedListing.setReview(_buyerCount);
        userRatings[seller].push(vars);
        return vars;
    }

    function getSellerReviews(address seller_) public view returns (reviewStruct[] memory) {
        return userRatings[seller_];
    }

    //use dis in de frontend to run through an array of all sellers and their listings
    function GetAllSellers() public view returns (address[] memory) {
        return allSellers;
    }

    function GetActiveListingsBySeller(address seller_) public view returns (ItemListing[] memory) {
        return userListings[seller_];
    }

    function checkListing(ItemListing listing) public view returns (bool) {
        return isListing[listing];
    }

    function GetAllActiveListings() public view returns (ItemListing[] memory) {
        ItemListing[] memory allActiveListings = new ItemListing[](allListings.length);
        uint256 count;
        for (uint256 i; i < allListings.length; i++) {
            ItemListing listing = ItemListing(allListings[i]);
            if (ItemListing(listing).getNumOfItemsLeft() >= 1) {
               allActiveListings[count++] = listing;
            }
        }
        return allActiveListings;
    }

    function GetActiveListingsByKeyword(string memory _keyword) public view returns (ItemListing[] memory) {
        ItemListing[] memory allActiveListings = new ItemListing[](allListings.length);
        uint256 count;
        for (uint256 i; i < allListings.length; i++) {
            ItemListing listing = ItemListing(allListings[i]);
            if (ItemListing(listing).getNumOfItemsLeft() >= 1 && compareStrings(ItemListing(listing).getKeyword(), _keyword) == true) {
               allActiveListings[count++] = listing;
            }
        }
        return allActiveListings;
    }

    function doesItHaveItemsLeft(ItemListing listing) public view returns (bool) {
        if (listing.getNumOfItemsLeft() >= 1) {
            return true;
        } else {
            return false;
        }
    }

    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}