// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title LazySanta contract
/// @notice This contract is for a token called LazySanta
contract LazySanta is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {

    // private variable to keep track of the next token Id
    uint256 private nextTokenId_;

    // price to mint a LazySanta
    uint256 public lazyFee;

    // current supply of LazySantas already minted
    uint256 public currentSupply;

    // maximum supply of LazySantas that can ever be minted
    uint256 public maxSupply;

    // uri of LazySanta
    string public uri;

    // public list of LazySanta lazyList
    address[] public lazyList;

    // mapping to keep track of number of mints each wallet has done
    mapping(address => uint256) public lazyWallets;

    // Event emitted when a LazySanta is minted
    event LazySantaMinted(address indexed minter, uint256 tokenId);

    /// @notice Deploy a new LazySanta contract
    /// @param chiefElf The address of the chief elf
    constructor(address chiefElf)
        ERC721("LazySanta", "LS")
        Ownable(chiefElf)
    {
        // initialize the next token id to 1 in the constructor
        nextTokenId_ = 1;

        // initialize maxSupply in constructor
        maxSupply = 20;

        // initialize lazyFee_ in constructor
        lazyFee = 0.01 * 1e18;

        // initialize uri in constructor
        uri = "ipfs://QmWj3UTHGEkcP2uHzk6wP4gzYQUKmKTZ4sVWLyiB7y9md7";
    }

    // struct to hold the proposed changes
    struct ProposedChange {
        uint256 lazyFee_;
        uint256 maxSupply_;
        string uri_;
        bool executed;
    }

    // mapping to store proposed changes
    mapping (address => ProposedChange) public proposedChanges;

    /// @notice Propose a change to the lazyFee
    /// @param lazyFee_ The proposed new lazyFee
    function proposeSetLazyFee(uint256 lazyFee_) external onlyOwner {
        proposedChanges[msg.sender] = ProposedChange(lazyFee_, maxSupply, uri, false);
    }

    /// @notice Propose a change to the maxSupply
    /// @param maxSupply_ The proposed new maxSupply
    function proposeSetMaxSupply(uint256 maxSupply_) external onlyOwner {
        proposedChanges[msg.sender] = ProposedChange(lazyFee, maxSupply_, uri, false);
    }

    /// @notice Propose a change to the uri
    /// @param uri_ The proposed new uri
    function proposeSetUri(string memory uri_) external onlyOwner {
        proposedChanges[msg.sender] = ProposedChange(lazyFee, maxSupply, uri_, false);
    }

    /// @notice Execute proposed changes
    function executeProposedChanges() external onlyOwner {
        require(!proposedChanges[msg.sender].executed, "Changes already executed!");
        lazyFee = proposedChanges[msg.sender].lazyFee_;
        maxSupply = proposedChanges[msg.sender].maxSupply_;
        uri = proposedChanges[msg.sender].uri_;
        proposedChanges[msg.sender].executed = true;
    }

    /// @notice Safely mint a LazySanta
    /// @dev Requires payment of the correct amount of ether and checks that the maximum supply has not been reached
    function safeMint() payable external {
        require(lazyWallets[msg.sender] < 1, "Max LazySanta mint per wallet exceeded!");
        require(msg.value == lazyFee, "Input accurate price of one LazySanta!");
        require(currentSupply < maxSupply, "All LazySantas have been minted!");


        lazyWallets[msg.sender]++;
        lazyList.push(msg.sender);
        currentSupply++;
        uint256 tokenId = currentSupply;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        nextTokenId_++;

        emit LazySantaMinted(msg.sender, tokenId);
    }

    /// @notice Function to withdraw all funds from the contract
    /// @dev This function can only be called by the owner of the contract
    function withdraw() external onlyOwner {
        // Reset the count of mints for each wallet
        for (uint256 lazyListIndex = 0; lazyListIndex < lazyList.length; lazyListIndex++) {
            address lazyMinter = lazyList[lazyListIndex];
            lazyWallets[lazyMinter] = 0;
        }
        // Clear the list of lazy wallets
        lazyList = new address[](0);

        // Get the balance of the contract
        uint256 contractBalance = address(this).balance;
        // Check if there are funds to withdraw
        require(contractBalance > 0, "No funds to withdraw");

        // Transfer funds before updating state variables to avoid reentrancy
        (bool callSuccess,) = payable(msg.sender).call{value: contractBalance}("");
        // Check if the transfer was successful
        require(callSuccess, "Withdrawal failed!");
    }


    // function to get all minters
    function getLazyList() external view onlyOwner returns(address[] memory) {
        return lazyList;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {// function to withdraw all funds from the contract
       
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
