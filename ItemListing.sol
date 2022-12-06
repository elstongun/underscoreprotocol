// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./openzeppelin/Ownable.sol";
import "./openzeppelin/ReentrancyGuard.sol";
import "./openzeppelin/IERC20.sol";
 
contract ItemListing is ReentrancyGuard {

    address public immutable seller;
    string name;
    string symbol;
    string imageURL;
    string keyword;
    uint256 public immutable WETHRequested;
    uint256 public numOfItems;
    uint256 public immutable fee;
    uint256 public immutable arbitratorFeePerItem;
    uint256 public buyerCount = 0;
    address[] public buyers;
    mapping(address => uint256) buyerApprovalMapping;
    mapping(uint256 => uint256) sellerApprovalMapping;
    mapping(uint256 => uint256) arbitratorApprovalMapping;
    mapping(address => bool) hasBuyerReviewed;
    mapping(uint256 => bool) hasEndedMapping;

    event ItemBought(address Buyer, address Seller, address Arbitrator, uint256 WETHRequested);
    event BuyerAprove(address Buyer, uint256 buyerApprove);
    event BuyerReject(address Buyer, uint256 buyerApprove);
    event SellerApprove(address Seller, uint256 sellerApprove);
    event ArbitratorApprove(address Arbitrator, uint256 arbitratorApprove);
    event ArbitratorReject(address Arbitrator, uint256 arbitratorApprove);
    event BuyerClaim(address Buyer, address Seller, address Listing, bool hasEnded);
    event SellerClaim(address Buyer, address Seller, address Listing, bool hasEnded);

    address WETH = 0x9c3DDc0Eba8C5d16018aA678fd2B009c8268e6fc;
    
    //ItemListing(name, symbol, imageURL, keyword, WETHRequested);
    address factory = msg.sender;
    address arbitrator = Ownable(factory).owner();
    
    /**
    0 = not approved
    1 = approved
    3 = not true or false but a secret third thing
        (jk its wen u want to undo a purchase because mr. buyer fucked u UwU)
    and they're 256 byes cuz fuck you

    bought is just true false with 0 false and 1 true
     */

    uint256 sellerApprove = 0;
    uint256 arbitratorApprove = 0;

    constructor (
        address _seller,
        string memory _name,
        string memory _symbol,
        string memory _imageURL,
        string memory _keyword,
        uint256 _numOfItems,
        uint256 _WETHRequested,
        uint256 _fee
        ) {
        seller = _seller;
        name = _name;
        symbol = _symbol;
        imageURL = _imageURL;
        keyword = _keyword;
        numOfItems = _numOfItems;
        fee = _fee;
        WETHRequested = _WETHRequested;
        arbitratorFeePerItem = (WETHRequested * fee) / 10000;
    }
    
    /**
     * @dev Throws if called by any account other than the Seller.
     */
    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }

    /**
     * @dev Throws if called by any account other than the Arbitrator.
     */
    modifier onlyArbitrator() {
        require(msg.sender == arbitrator);
        _;
    }

    /**
     * @dev Throws if called by any account other than the Factory.
     */
    modifier onlyFactory() {
        require(msg.sender == factory);
        _;
    }

    function getWETH() public view returns (uint256) {
        uint256 escrowWETH = IERC20(WETH).balanceOf(address(this));
        return escrowWETH;
    }

    function buyItem() public nonReentrant returns (uint256) {
        require(msg.sender != seller || msg.sender != arbitrator, "no insider tradin"); // no insider tradinnn!
        require(numOfItems >= 0);
        require(IERC20(WETH).balanceOf(msg.sender) >= WETHRequested, "not enough weth"); // U TOO POOR

        IERC20(WETH).transferFrom(msg.sender, address(this), (WETHRequested - arbitratorFeePerItem));
        IERC20(WETH).transferFrom(address(this), arbitrator, arbitratorFeePerItem);

        emit ItemBought(msg.sender, seller, arbitrator, WETHRequested);
        buyers[buyerCount] = msg.sender;
        numOfItems -= 1;
        buyerCount += 1;
        return buyerCount;
    }

    //buyer approval to give seller moneys once item is received
    function buyerApproval(address buyer, uint256 _buyerCount) external nonReentrant returns (uint256) {
        require(msg.sender == buyers[_buyerCount]);
        require(buyerApprovalMapping[buyer] == 0);

        emit BuyerAprove(buyer, 1);
        buyerApprovalMapping[buyer] = 1;
        return buyerApprovalMapping[buyer];
    }

    //for returning funds to da buyer if the seller betways dem
    function buyerReject(address buyer, uint256 _buyerCount) external nonReentrant returns (uint256) {
        require(msg.sender == buyers[_buyerCount]);
        require(buyerApprovalMapping[buyer] == 0);

        emit BuyerReject(buyer, 3);
        buyerApprovalMapping[buyer] = 3;        
        return buyerApprovalMapping[buyer];
    }

    //for seller approving 1nce dey send da item
    function sellerApprovalByBuyer(uint256 _buyerCount) external onlySeller nonReentrant returns (uint256) {
        require(sellerApprovalMapping[_buyerCount] == 0);

        emit SellerApprove(seller, 1);
        sellerApprovalMapping[_buyerCount] = 1;
        return 1;
    }

    //arbitrator approval to give funds to seller
    function arbitratorApproval(uint256 _buyerCount) external onlyArbitrator nonReentrant returns (uint256) {
        require(arbitratorApprovalMapping[_buyerCount] == 0);

        emit ArbitratorApprove(arbitrator, 1);
        arbitratorApprovalMapping[_buyerCount] = 1;
        return 1;
    }

    //for returning funds to da buyer if the seller betways dem
    function arbitratorReject(uint256 _buyerCount) external onlyArbitrator nonReentrant returns (uint256) {
        require(arbitratorApprovalMapping[_buyerCount] == 0);

        emit ArbitratorReject(arbitrator, arbitratorApprove);
        arbitratorApprovalMapping[_buyerCount] = 3;
        return arbitratorApprove;
    }

    //for buyer to get bak moneyz if dey get screwed over
    //if true then dey get deir money bak
    //if false den NOT APPROVED YET!!!!11!
    function buyerClaim(uint256 _buyerCount) public nonReentrant returns (bool) {
        require(msg.sender == buyers[_buyerCount]);
        if (arbitratorApprovalMapping[_buyerCount] == 3 && buyerApprovalMapping[buyers[_buyerCount]] == 3) {
           
            IERC20(WETH).transfer(buyers[_buyerCount], IERC20(WETH).balanceOf(address(this)));

            emit BuyerClaim(buyers[_buyerCount], seller, address(this), true);
            hasEndedMapping[_buyerCount] = true;
            return hasEndedMapping[_buyerCount];
        }
        else {
            return hasEndedMapping[_buyerCount];
        }
    }

    //for seller to claim moneyz if dey wer good boyz/girlz
    //if returns true then moneyz transferred
    //if false den NOT APPROVED YET!!!!11!
    function sellerClaim(uint256 _buyerCount) public onlySeller nonReentrant returns (bool) {
        if (buyerApprovalMapping[buyers[_buyerCount]] == 1 && sellerApprove == 1) {
            IERC20(WETH).transfer(seller, (WETHRequested - arbitratorFeePerItem));
            
            emit SellerClaim(buyers[_buyerCount], seller, address(this), true);
            hasEndedMapping[_buyerCount] = true;
            return hasEndedMapping[_buyerCount];
        }
        else if (arbitratorApprove == 1 && sellerApprove == 1) {
            IERC20(WETH).transfer(seller, (WETHRequested - arbitratorFeePerItem));

            emit SellerClaim(buyers[_buyerCount], seller, address(this), true);
            hasEndedMapping[_buyerCount] = true;
            return hasEndedMapping[_buyerCount];
        }
        else {
            return hasEndedMapping[_buyerCount];
        }
    }

    function setReview(uint256 _buyerCount) public onlyFactory returns (bool) {
        hasBuyerReviewed[getIndividualBuyer(_buyerCount)] = true;
        return hasBuyerReviewed[getIndividualBuyer(_buyerCount)];
    }

    function isReviewed(uint256 _buyerCount) public view returns (bool) {
        return hasBuyerReviewed[getIndividualBuyer(_buyerCount)];
    }

    function getBuyers() public view returns (address[] memory) {
        return buyers;
    }

    function getBuyerCount() public view returns (uint256) {
        return buyerCount;
    }

    function getNumOfItemsLeft() public view returns (uint256) {
        return numOfItems;
    }

    function getIndividualBuyer(uint256 _buyerCount) public view returns (address) {
        return buyers[_buyerCount];
    }
    
    function getSeller() public view returns (address) {
        return seller;
    }

    function getURL() public view returns (string memory) {
        return imageURL;
    }

    function getKeyword() public view returns (string memory) {
        return keyword;
    }

    function getFactory() public view returns (address) {
        return factory;
    }

    //iz we done????!?
    function isItOverByBuyer(uint256 _buyerCount) public view returns (bool) {
        return hasEndedMapping[_buyerCount];
    }
}