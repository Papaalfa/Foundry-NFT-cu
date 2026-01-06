// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private sTokenCounter;
    mapping(uint256 => string) private sTokenIdToUri;

    // Custom error (cheaper than string revert messages)
    error BasicNft__TokenDoesNotExist(uint256 tokenId);

    constructor() ERC721("Dogie", "DOG") {
        sTokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        sTokenIdToUri[sTokenCounter] = tokenUri;
        _safeMint(msg.sender, sTokenCounter);
        sTokenCounter++;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) {
            revert BasicNft__TokenDoesNotExist(tokenId);
        }
        return sTokenIdToUri[tokenId];
    }

    // Optional: expose token counter for easier testing/debugging
    function getTokenCounter() public view returns (uint256) {
        return sTokenCounter;
    }
}
