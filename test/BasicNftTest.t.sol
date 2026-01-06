// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";

contract BasicNftTest is Test {
    BasicNft public basicNft;
    DeployBasicNft public deployer;

    address public USER = makeAddr("user");
    address public USER2 = makeAddr("user2");

    string constant TEST_URI_1 =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    string constant TEST_URI_2 =
        "ipfs://QmShibaInuFakeHashForTestingPurposeOnly";

    // Declare the Transfer event from ERC721
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    // Declare your custom error from BasicNft
    error BasicNft__TokenDoesNotExist(uint256 tokenId);
    // OpenZeppelin's custom error for nonexistent tokens (used in ownerOf and others)
    error ERC721NonexistentToken(uint256 tokenId);

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    /* ========== Basic Checks ========== */

    function testNameAndSymbolAreCorrect() public view {
        assertEq(basicNft.name(), "Dogie");
        assertEq(basicNft.symbol(), "DOG");
    }

    function testMintNftAndTokenUri() public {
        vm.prank(USER);
        basicNft.mintNft(TEST_URI_1);

        assertEq(basicNft.ownerOf(0), USER);
        assertEq(basicNft.tokenURI(0), TEST_URI_1);
        assertEq(basicNft.balanceOf(USER), 1);
    }

    /* ========== Additional Core Tests ========== */

    function testMultipleMintsWorkCorrectly() public {
        vm.prank(USER);
        basicNft.mintNft(TEST_URI_1);

        vm.prank(USER2);
        basicNft.mintNft(TEST_URI_2);

        assertEq(basicNft.ownerOf(0), USER);
        assertEq(basicNft.ownerOf(1), USER2);
        assertEq(basicNft.tokenURI(0), TEST_URI_1);
        assertEq(basicNft.tokenURI(1), TEST_URI_2);
        assertEq(basicNft.balanceOf(USER), 1);
        assertEq(basicNft.balanceOf(USER2), 1);
    }

    function testCannotGetTokenUriForNonExistentToken() public {
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft__TokenDoesNotExist.selector, 999)
        );
        basicNft.tokenURI(999);
    }

    function testCannotGetOwnerOfNonExistentToken() public {
        // OpenZeppelin now uses custom error ERC721NonexistentToken(address,uint256)
        // For a nonexistent token, owner is address(0)
        vm.expectRevert(
            abi.encodeWithSelector(ERC721NonexistentToken.selector, 999)
        );
        basicNft.ownerOf(999);
    }

    function testMintEmitsTransferEvent() public {
        vm.prank(USER);

        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), USER, 0);

        basicNft.mintNft(TEST_URI_1);
    }

    function testSupportsStandardERC721Interfaces() public view {
        assertTrue(basicNft.supportsInterface(0x80ac58cd)); // ERC721
        assertTrue(basicNft.supportsInterface(0x5b5e139f)); // ERC721 Metadata
        assertTrue(basicNft.supportsInterface(0x01ffc9a7)); // ERC165
        assertFalse(basicNft.supportsInterface(0xaaaaaaaa));
    }

    function testSafeMintRejectsNonReceiverContract() public {
        NonReceiver nonReceiver = new NonReceiver();

        vm.prank(address(nonReceiver));
        // OpenZeppelin custom error for invalid receiver
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InvalidReceiver(address)",
                address(nonReceiver)
            )
        );
        basicNft.mintNft(TEST_URI_1);
    }

    /* ========== Fuzz Test ========== */

    function testFuzz_MintAndCheckTokenUri(string calldata uri) public {
        vm.assume(bytes(uri).length > 0);

        uint256 initialBalance = basicNft.balanceOf(USER);

        vm.prank(USER);
        basicNft.mintNft(uri);

        uint256 tokenId = initialBalance; // tokenId starts at 0 and increments
        assertEq(basicNft.tokenURI(tokenId), uri);
        assertEq(basicNft.ownerOf(tokenId), USER);
        assertEq(basicNft.balanceOf(USER), initialBalance + 1);
    }
}

/* Helper contract to test _safeMint receiver check */
contract NonReceiver {
    // Intentionally empty — does not implement onERC721Received
}
