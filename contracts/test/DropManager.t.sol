// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { DropManager } from "../src/DropManager.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { ERC721ConsecutiveMock } from "@openzeppelin/contracts/mocks/token/ERC721ConsecutiveMock.sol";

contract ManagerTest is Test {
	DropManager dm;

	function setUp() public {
		dm = new DropManager();
	}

	function testCreateDropLockERC20() public {
		vm.startPrank(msg.sender);
		ERC20Mock token = new ERC20Mock();
		token.mint(msg.sender, 100000);
		bytes32 hashedPassword = keccak256(abi.encodePacked("pwpwpwpwpwp"));

		uint256 balance = token.balanceOf(msg.sender);
		assertEq(balance, 100000, "Minting failed");

		token.approve(address(dm), 100);
		uint256 allowance = token.allowance(msg.sender, address(dm));
		assertEq(allowance, 100, "Approval failed");

		bytes32 id = keccak256(
			abi.encodePacked(msg.sender, dm.userNonces(msg.sender))
		);

		dm.createDropLockERC20(
			hashedPassword,
			address(token),
			100,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		balance = token.balanceOf(msg.sender);

		assertEq(sender, msg.sender);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "erc20");
		assertEq(contractAddress, address(token));
		assertEq(amount, 100);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(balance, 99900, "Token transfer failed");

		vm.stopPrank();
	}

	function testCreateDropLockETH() public {
		vm.startPrank(msg.sender);
		bytes32 hashedPassword = keccak256(abi.encodePacked("pwpwpwpwpwp"));

		uint256 ethAmount = 1000000;

		bytes32 id = keccak256(
			abi.encodePacked(msg.sender, dm.userNonces(msg.sender))
		);

		dm.createDropLockETH{ value: ethAmount }(
			hashedPassword,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		assertEq(sender, msg.sender);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "eth");
		assertEq(contractAddress, address(0));
		assertEq(amount, ethAmount);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(address(dm).balance, ethAmount);

		vm.stopPrank();
	}

	function testCreateDropLockERC721() public {
		vm.startPrank(msg.sender);
		address[] memory arg = new address[](1);
		arg[0] = msg.sender;
		uint96[] memory arg2 = new uint96[](1);
		arg2[0] = 1;
		ERC721ConsecutiveMock token = new ERC721ConsecutiveMock(
			"test",
			"test",
			0,
			arg,
			arg,
			arg2
		);

		bytes32 hashedPassword = keccak256(abi.encodePacked("pwpwpwpwpwp"));

		uint256 balance = token.balanceOf(msg.sender);
		assertEq(balance, 1, "Minting failed");

		uint256 tokenId = 0;

		token.approve(address(dm), tokenId);

		bytes32 id = keccak256(
			abi.encodePacked(msg.sender, dm.userNonces(msg.sender))
		);

		dm.createDropLockERC721(
			hashedPassword,
			address(token),
			tokenId,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		balance = token.balanceOf(msg.sender);

		assertEq(sender, msg.sender);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "erc721");
		assertEq(contractAddress, address(token));
		assertEq(amount, tokenId);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(balance, 0, "Token transfer failed");

		vm.stopPrank();
	}

	function testUnlockWithStolenProof() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		vm.deal(locker, 2 ether);
		vm.prank(locker);
		ERC20Mock token = new ERC20Mock();
		vm.prank(locker);
		token.mint(locker, 100000);
		bytes32 passHash = keccak256("password111");
		bytes32 hashedPassword = keccak256(abi.encodePacked(passHash, locker));

		uint256 balance = token.balanceOf(locker);
		assertEq(balance, 100000, "Minting failed");
		vm.prank(locker);
		token.approve(address(dm), 100);
		uint256 allowance = token.allowance(locker, address(dm));
		assertEq(allowance, 100, "Approval failed");

		bytes32 id = keccak256(abi.encodePacked(locker, dm.userNonces(locker)));
		vm.prank(locker);
		dm.createDropLockERC20(
			hashedPassword,
			address(token),
			100,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		balance = token.balanceOf(locker);

		assertEq(sender, locker);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "erc20");
		assertEq(contractAddress, address(token));
		assertEq(amount, 100);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(balance, 99900, "Token transfer failed");

		// proof was generated with correct PW, but by a different address (0x2465F36F0Cf94d4bea77A6f1D775984274461e36)
		uint256 uPk = 0x1234;
		address unlocker = vm.addr(uPk);

		vm.deal(unlocker, 2 ether);
		vm.prank(unlocker);
		DropManager.ProofData memory proof = DropManager.ProofData({
			a0: 0x022c3685bc4987ddc190a4da2155693777e4e5bde82f9306daaffc842a577650,
			a1: 0x1c808fd44f555742e802c2cf571551e9aee02d09e12f1c733a6cfbc341ac85ff,
			b00: 0x14d7cb4cca72efb6954662783d2324a2b542ced6371b69911c55933ce90531ff,
			b01: 0x200efff05fec47f01f936a4e0be4ee1b8c2fcb6bea4ec9d61b59ed7cf5e2dcdf,
			b10: 0x2e47e8ca97e4b62ecb5322431a1d1f1c925859a86785f61ba4b30815c2718966,
			b11: 0x0e1988538457b48dcd4ca2b644d55f30b5c352b6b66cb61aea8afa2df4d375ca,
			c0: 0x20542ba620f1d7d40c09328ce02cbb53b9a85a9171cf2b2a947d4a50cd30fc3c,
			c1: 0x2618f90d8797e031b6ca6995c63c261538c712834c23a8d2b81d6624b4963b8c
		});

		vm.expectRevert("Proof Not Verified");
		dm.unlockDrop(proof, id);
	}

	function testUnlockERC20() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		vm.deal(locker, 2 ether);
		vm.prank(locker);
		ERC20Mock token = new ERC20Mock();
		vm.prank(locker);
		token.mint(locker, 100000);
		bytes32 passHash = keccak256("password111");
		bytes32 hashedPassword = keccak256(abi.encodePacked(passHash, locker));

		uint256 balance = token.balanceOf(locker);
		assertEq(balance, 100000, "Minting failed");
		vm.prank(locker);
		token.approve(address(dm), 100);
		uint256 allowance = token.allowance(locker, address(dm));
		assertEq(allowance, 100, "Approval failed");

		bytes32 id = keccak256(abi.encodePacked(locker, dm.userNonces(locker)));
		vm.prank(locker);
		dm.createDropLockERC20(
			hashedPassword,
			address(token),
			100,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		balance = token.balanceOf(locker);

		assertEq(sender, locker);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "erc20");
		assertEq(contractAddress, address(token));
		assertEq(amount, 100);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(balance, 99900, "Token transfer failed");

		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 unlockHash = keccak256(abi.encodePacked(passHash, unlocker));

		vm.deal(unlocker, 2 ether);
		vm.prank(unlocker);
		DropManager.ProofData memory proof = DropManager.ProofData({
			a0: 0x022c3685bc4987ddc190a4da2155693777e4e5bde82f9306daaffc842a577650,
			a1: 0x1c808fd44f555742e802c2cf571551e9aee02d09e12f1c733a6cfbc341ac85ff,
			b00: 0x14d7cb4cca72efb6954662783d2324a2b542ced6371b69911c55933ce90531ff,
			b01: 0x200efff05fec47f01f936a4e0be4ee1b8c2fcb6bea4ec9d61b59ed7cf5e2dcdf,
			b10: 0x2e47e8ca97e4b62ecb5322431a1d1f1c925859a86785f61ba4b30815c2718966,
			b11: 0x0e1988538457b48dcd4ca2b644d55f30b5c352b6b66cb61aea8afa2df4d375ca,
			c0: 0x20542ba620f1d7d40c09328ce02cbb53b9a85a9171cf2b2a947d4a50cd30fc3c,
			c1: 0x2618f90d8797e031b6ca6995c63c261538c712834c23a8d2b81d6624b4963b8c
		});

		dm.unlockDrop(proof, id);
		balance = token.balanceOf(unlocker);
		assertEq(amount, balance);
	}

	function testUnlockERC721() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		vm.deal(locker, 2 ether);
		address[] memory arg = new address[](1);
		arg[0] = locker;
		uint96[] memory arg2 = new uint96[](1);
		arg2[0] = 1;
		vm.prank(locker);
		ERC721ConsecutiveMock token = new ERC721ConsecutiveMock(
			"test",
			"test",
			0,
			arg,
			arg,
			arg2
		);

		bytes32 passHash = keccak256("password111");
		bytes32 hashedPassword = keccak256(abi.encodePacked(passHash, locker));

		uint256 balance = token.balanceOf(locker);
		assertEq(balance, 1, "Minting failed");

		uint256 tokenId = 0;

		vm.prank(locker);
		token.approve(address(dm), tokenId);

		bytes32 id = keccak256(abi.encodePacked(locker, dm.userNonces(locker)));
		vm.prank(locker);
		dm.createDropLockERC721(
			hashedPassword,
			address(token),
			tokenId,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		balance = token.balanceOf(address(dm));

		assertEq(sender, locker);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "erc721");
		assertEq(contractAddress, address(token));
		assertEq(amount, tokenId);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(balance, 1, "Token transfer failed");

		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 unlockHash = keccak256(abi.encodePacked(passHash, unlocker));

		vm.deal(unlocker, 2 ether);
		DropManager.ProofData memory proof = DropManager.ProofData({
			a0: 0x022c3685bc4987ddc190a4da2155693777e4e5bde82f9306daaffc842a577650,
			a1: 0x1c808fd44f555742e802c2cf571551e9aee02d09e12f1c733a6cfbc341ac85ff,
			b00: 0x14d7cb4cca72efb6954662783d2324a2b542ced6371b69911c55933ce90531ff,
			b01: 0x200efff05fec47f01f936a4e0be4ee1b8c2fcb6bea4ec9d61b59ed7cf5e2dcdf,
			b10: 0x2e47e8ca97e4b62ecb5322431a1d1f1c925859a86785f61ba4b30815c2718966,
			b11: 0x0e1988538457b48dcd4ca2b644d55f30b5c352b6b66cb61aea8afa2df4d375ca,
			c0: 0x20542ba620f1d7d40c09328ce02cbb53b9a85a9171cf2b2a947d4a50cd30fc3c,
			c1: 0x2618f90d8797e031b6ca6995c63c261538c712834c23a8d2b81d6624b4963b8c
		});
		vm.prank(unlocker);
		dm.unlockDrop(proof, id);
		balance = token.balanceOf(unlocker);
		assertEq(balance, 1);
	}

	function testUnlockETH() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		vm.deal(locker, 2 ether);

		uint256 ethAmount = 1000000;
		bytes32 passHash = keccak256("password111");
		bytes32 hashedPassword = keccak256(abi.encodePacked(passHash, locker));
		bytes32 id = keccak256(abi.encodePacked(locker, dm.userNonces(locker)));
		vm.prank(locker);
		dm.createDropLockETH{ value: ethAmount }(
			hashedPassword,
			block.timestamp + 86400
		);

		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = dm.getDropLockById(id);

		assertEq(sender, locker);
		assertEq(hPass, hashedPassword);
		assertEq(prizeType, "eth");
		assertEq(contractAddress, address(0));
		assertEq(amount, ethAmount);
		assertEq(expiry, block.timestamp + 86400);
		assertEq(address(dm).balance, ethAmount);

		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 unlockHash = keccak256(abi.encodePacked(passHash, unlocker));

		vm.deal(unlocker, 2 ether);
		vm.prank(unlocker);
		DropManager.ProofData memory proof = DropManager.ProofData({
			a0: 0x022c3685bc4987ddc190a4da2155693777e4e5bde82f9306daaffc842a577650,
			a1: 0x1c808fd44f555742e802c2cf571551e9aee02d09e12f1c733a6cfbc341ac85ff,
			b00: 0x14d7cb4cca72efb6954662783d2324a2b542ced6371b69911c55933ce90531ff,
			b01: 0x200efff05fec47f01f936a4e0be4ee1b8c2fcb6bea4ec9d61b59ed7cf5e2dcdf,
			b10: 0x2e47e8ca97e4b62ecb5322431a1d1f1c925859a86785f61ba4b30815c2718966,
			b11: 0x0e1988538457b48dcd4ca2b644d55f30b5c352b6b66cb61aea8afa2df4d375ca,
			c0: 0x20542ba620f1d7d40c09328ce02cbb53b9a85a9171cf2b2a947d4a50cd30fc3c,
			c1: 0x2618f90d8797e031b6ca6995c63c261538c712834c23a8d2b81d6624b4963b8c
		});

		dm.unlockDrop(proof, id);
		uint256 balance = unlocker.balance;
		assertTrue(balance > 2 ether);
	}
}
