// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract MintBasicNft is Script {
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        address mostRecentlyDeployedBasic = DevOpsTools
            .get_most_recent_deployment("BasicNft", block.chainid);

        mintNftOnContract(mostRecentlyDeployedBasic);
    }

    function mintNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        BasicNft(contractAddress).mintNft(PUG);
        vm.stopBroadcast();
    }
}

contract MintMoodNft is Script {
    function run() external {
        address mostRecentlyDeployedMood = DevOpsTools
            .get_most_recent_deployment("MoodNft", block.chainid);

        mintNftOnContract(mostRecentlyDeployedMood);
    }

    function mintNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        MoodNft(contractAddress).mintNft();
        vm.stopBroadcast();
    }
}

contract FlipMoodNft is Script {
    uint256 public tokenId = vm.envUint("TOKEN_ID");

    function run() external {
        address mostRecentlyDeployedMood = DevOpsTools
            .get_most_recent_deployment("MoodNft", block.chainid);

        flipMoodNftOnContract(mostRecentlyDeployedMood, tokenId);
    }

    function flipMoodNftOnContract(
        address contractAddress,
        uint256 tokenId2flip
    ) public {
        vm.startBroadcast();
        MoodNft(contractAddress).flipMood(tokenId2flip);
        vm.stopBroadcast();
    }
}
