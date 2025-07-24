// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import hardcoded counter implementation instead of relying on OpenZeppelin
contract PurchaseReceiptNFT {
    // Simple counter implementation
    struct Counter {
        uint256 _value;
    }
    
    // Counter utility functions
    function current(Counter storage counter) private view returns (uint256) {
        return counter._value;
    }
    
    function increment(Counter storage counter) private {
        counter._value += 1;
    }
    
    // NFT storage variables
    string private _name;
    string private _symbol;
    address private _owner;
    
    Counter private _receiptIds;
    
    // Mappings for NFT functionality
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _tokenURIs;
    
    struct Receipt {
        uint256 courseId;
        uint256 pricePaid;
        uint256 timestamp;
    }
    
    mapping(uint256 => Receipt) public receiptDetails;
    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event ReceiptMinted(
        uint256 indexed receiptId,
        address indexed purchaser,
        uint256 courseId,
        uint256 pricePaid
    );
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
    
    constructor() {
        _name = "PurchaseReceiptNFT";
        _symbol = "PRNFT";
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    // Basic NFT functions
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    function balanceOf(address owner_) public view returns (uint256) {
        require(owner_ != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner_];
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner_ = _owners[tokenId];
        require(owner_ != address(0), "ERC721: invalid token ID");
        return owner_;
    }
    
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: invalid token ID");
        return _tokenURIs[tokenId];
    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    function _safeMint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        
        _balances[to] += 1;
        _owners[tokenId] = to;
        
        emit Transfer(address(0), to, tokenId);
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    // Contract-specific functions
    
    /// @notice Mint receipt - only owner (backend) can mint
    function adminMintReceipt(
        address purchaser,
        uint256 courseId,
        uint256 pricePaid,
        string memory tokenURI_
    ) external onlyOwner returns (uint256) {
        require(purchaser != address(0), "Invalid purchaser address");
        
        increment(_receiptIds);
        uint256 newReceiptId = current(_receiptIds);
        
        _safeMint(purchaser, newReceiptId);
        _setTokenURI(newReceiptId, tokenURI_);
        
        receiptDetails[newReceiptId] = Receipt({
            courseId: courseId,
            pricePaid: pricePaid,
            timestamp: block.timestamp
        });
        
        emit ReceiptMinted(newReceiptId, purchaser, courseId, pricePaid);
        return newReceiptId;
    }
    
    function getReceiptData(uint256 receiptId) external view returns (Receipt memory) {
        require(_exists(receiptId), "Receipt does not exist");
        return receiptDetails[receiptId];
    }
}