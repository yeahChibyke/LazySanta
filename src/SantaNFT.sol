// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

    constructor(address chiefElf)
        ERC721("LazySanta", "LS")
        Ownable(chiefElf)
    {
        // initialize the next token id to 1 in the constructor
        nextTokenId_ = 1;

        // initialize maxSupply in constructor
        maxSupply = 20;

        // initialize lazyFee_ in constructor
        lazyFee = 0.01 ether;

        // initialize uri in constructor
        uri = "ipfs://QmWj3UTHGEkcP2uHzk6wP4gzYQUKmKTZ4sVWLyiB7y9md7";
    }

    // function to set the mint price
    function setlazyFee_(uint256 lazyFee_) external onlyOwner {
        lazyFee = lazyFee_;
    }

    // function to set the maximum supply
    function setMaxSupply(uint256 maxSupply_) external onlyOwner {
        maxSupply = maxSupply_;
    }

    // function to set the uri
    function setUri(string memory uri_) external onlyOwner {
        uri = uri_;
    }

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
    }

    function withdraw() external onlyOwner {
         for(uint256 lazyListIndex = 0; lazyListIndex < lazyList.length; lazyListIndex++) {
            address lazyMinter = lazyList[lazyListIndex];
            lazyWallets[lazyMinter] = 0;
        }
        lazyList = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed!");
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