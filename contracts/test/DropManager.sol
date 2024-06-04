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
}
