// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    // errors
    error MoodNft__CantFlipMoodIfNotOwnerOrApproved();

    uint256 private sTokenCounter;
    string private sHappySvgImageUri;
    string private sSadSvgImageUri;

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private sTokenIdToMood;

    constructor(
        string memory happySvgImageUri,
        string memory sadSvgImageUri
    ) ERC721("Mood NFT", "MN") {
        sHappySvgImageUri = happySvgImageUri;
        sSadSvgImageUri = sadSvgImageUri;
        sTokenCounter = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, sTokenCounter);
        sTokenIdToMood[sTokenCounter] = Mood.HAPPY;
        sTokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        // Standard check compatible with OpenZeppelin v5
        address owner = ownerOf(tokenId);
        if (
            msg.sender != owner &&
            msg.sender != getApproved(tokenId) &&
            !isApprovedForAll(owner, msg.sender)
        ) {
            revert MoodNft__CantFlipMoodIfNotOwnerOrApproved();
        }

        if (sTokenIdToMood[tokenId] == Mood.HAPPY) {
            sTokenIdToMood[tokenId] = Mood.SAD;
        } else {
            sTokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageUri;
        if (sTokenIdToMood[tokenId] == Mood.HAPPY) {
            imageUri = sHappySvgImageUri;
        } else {
            imageUri = sSadSvgImageUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                name(),
                                '", "description": "An NFT that reflects the owner\'s mood.", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": "',
                                imageUri,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
