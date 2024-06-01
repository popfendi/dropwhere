// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Verifier } from "./zk-verifier/verifier.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";

//import "forge-std/console.sol"; //REMOVE AFTER TESTING

contract DropManager is IERC721Receiver {
	struct Drop {
		address sender;
		bytes32 hashedPassword;
		string prizeType;
		address contractAddress;
		uint256 amount;
		uint256 expiry;
	}

	mapping(bytes32 => Drop) public drops;
	mapping(address => uint256) public userNonces;

	event DropAdded(
		bytes32 indexed id,
		address indexed sender,
		bytes32 hashedPassword,
		string prizeType,
		address contractAddress,
		uint256 amount,
		uint256 expiry
	);

	constructor() {}

	function createDropLockERC20(
		bytes32 hashedPassword,
		address contractAddress,
		uint256 amount,
		uint256 expiry
	) public {
		require(
			expiry >= block.timestamp + 86400,
			"Expiry must be at least 24 hours from now"
		);
		uint256 initialBalance = IERC20(contractAddress).balanceOf(
			address(this)
		);

		IERC20 token = IERC20(contractAddress);
		require(
			token.transferFrom(msg.sender, address(this), amount),
			"Transfer failed"
		);

		uint256 finalBalance = IERC20(contractAddress).balanceOf(address(this));
		uint256 actualAmount = finalBalance - initialBalance;

		bytes32 id = keccak256(
			abi.encodePacked(msg.sender, userNonces[msg.sender])
		);

		drops[id] = Drop({
			sender: msg.sender,
			hashedPassword: hashedPassword,
			prizeType: "erc20",
			contractAddress: contractAddress,
			amount: actualAmount,
			expiry: expiry
		});

		emit DropAdded(
			id,
			msg.sender,
			hashedPassword,
			"erc20",
			contractAddress,
			actualAmount,
			expiry
		);

		userNonces[msg.sender]++;
	}

	function createDropLockETH(
		bytes32 hashedPassword,
		uint256 expiry
	) public payable {
		require(
			expiry >= block.timestamp + 86400,
			"Expiry must be at least 24 hours from now"
		);
		require(msg.value > 0, "Amount must be greater than zero");

		bytes32 id = keccak256(
			abi.encodePacked(msg.sender, userNonces[msg.sender])
		);

		drops[id] = Drop({
			sender: msg.sender,
			hashedPassword: hashedPassword,
			prizeType: "eth",
			contractAddress: address(0),
			amount: msg.value,
			expiry: expiry
		});

		emit DropAdded(
			id,
			msg.sender,
			hashedPassword,
			"eth",
			address(0),
			msg.value,
			expiry
		);

		userNonces[msg.sender]++;
	}

	// amount in this case refers to tokenId
	function createDropLockERC721(
		bytes32 hashedPassword,
		address contractAddress,
		uint256 tokenId,
		uint256 expiry
	) public {
		require(
			expiry >= block.timestamp + 86400,
			"Expiry must be at least 24 hours from now"
		);

		IERC721 token = IERC721(contractAddress);

		token.safeTransferFrom(msg.sender, address(this), tokenId);

		bytes32 id = keccak256(
			abi.encodePacked(msg.sender, userNonces[msg.sender])
		);

		drops[id] = Drop({
			sender: msg.sender,
			hashedPassword: hashedPassword,
			prizeType: "erc721",
			contractAddress: contractAddress,
			amount: tokenId,
			expiry: expiry
		});

		emit DropAdded(
			id,
			msg.sender,
			hashedPassword,
			"erc721",
			contractAddress,
			tokenId,
			expiry
		);

		userNonces[msg.sender]++;
	}

	function onERC721Received(
		address operator,
		address from,
		uint256 tokenId,
		bytes calldata data
	) external override returns (bytes4) {
		return this.onERC721Received.selector;
	}
}
