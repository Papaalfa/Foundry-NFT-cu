// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNft is Script {
    function run() external returns (MoodNft) {
        string memory happySvg = vm.readFile("./img/happy.svg");
        string memory sadSvg = vm.readFile("./img/sad.svg");

        string memory happyImageUri = svgToImageUri(happySvg);
        string memory sadImageUri = svgToImageUri(sadSvg);

        vm.startBroadcast();
        MoodNft moodNft = new MoodNft(happyImageUri, sadImageUri);
        vm.stopBroadcast();
        return moodNft;
    }

    function svgToImageUri(
        string memory svg
    ) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string.concat(svg))
        );
        return string.concat(baseUrl, svgBase64Encoded);
    }
}
