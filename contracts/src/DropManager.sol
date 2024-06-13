// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Verifier, Pairing } from "./zk-verifier/verifier.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";

import "forge-std/console.sol"; //REMOVE AFTER TESTING

contract DropManager is IERC721Receiver {
	struct Drop {
		address sender;
		bytes32 hashedPassword;
		string prizeType;
		address contractAddress;
		uint256 amount;
		uint256 expiry;
	}

	struct ProofData {
		bytes32 a0;
		bytes32 a1;
		bytes32 b00;
		bytes32 b01;
		bytes32 b10;
		bytes32 b11;
		bytes32 c0;
		bytes32 c1;
	}

	mapping(bytes32 => Drop) public drops;
	mapping(address => uint256) public userNonces;

	Verifier public verifier;

	event DropAdded(
		bytes32 indexed id,
		address indexed sender,
		bytes32 hashedPassword,
		string prizeType,
		address contractAddress,
		uint256 amount,
		uint256 expiry
	);

	event DropUnlocked(
		bytes32 indexed id,
		address indexed sender,
		address indexed reciever,
		bytes32 hashedPassword,
		string prizeType,
		address contractAddress,
		uint256 amount,
		uint256 expiry
	);

	constructor() {
		verifier = new Verifier();
	}

	function getDropLockById(
		bytes32 id
	)
		public
		view
		returns (address, bytes32, string memory, address, uint256, uint256)
	{
		Drop storage d = drops[id];
		return (
			d.sender,
			d.hashedPassword,
			d.prizeType,
			d.contractAddress,
			d.amount,
			d.expiry
		);
	}

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

	function compareStrings(
		string memory a,
		string memory b
	) internal pure returns (bool) {
		return (keccak256(abi.encodePacked((a))) ==
			keccak256(abi.encodePacked((b))));
	}

	function convertToUint256Array(
		address addr1,
		address addr2,
		bytes32 b1
	) internal pure returns (uint256[72] memory) {
		uint256[72] memory result;

		for (uint256 i = 0; i < 20; i++) {
			result[i] = uint256(uint8(bytes20(addr1)[i]));
			result[i + 20] = uint256(uint8(bytes20(addr2)[i]));
		}

		for (uint256 i = 0; i < 32; i++) {
			result[i + 40] = uint256(uint8(b1[i]));
		}

		return result;
	}

	function transferERC20(
		address to,
		address contractAddress,
		uint256 amount
	) internal {
		IERC20 token = IERC20(contractAddress);
		require(token.transfer(to, amount), "Transfer failed");
	}

	function transferERC721(
		address to,
		address contractAddress,
		uint256 tokenId
	) internal {
		IERC721 token = IERC721(contractAddress);
		token.safeTransferFrom(address(this), to, tokenId);
	}

	function transferETH(address to, uint256 amount) internal {
		(bool success, ) = to.call{ value: amount }("");
		require(success, "Transfer failed.");
	}

	function unlockDrop(ProofData memory proof, bytes32 lockId) public {
		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = getDropLockById(lockId);

		require(!compareStrings(prizeType, ""), "Drop Doesn't Exist");
		require(block.timestamp < expiry, "Lock Has Expired");

		uint[2] memory a = [uint256(proof.a0), uint256(proof.a1)];
		uint[2][2] memory b = [
			[uint256(proof.b00), uint256(proof.b01)],
			[uint256(proof.b10), uint256(proof.b11)]
		];
		uint[2] memory c = [uint256(proof.c0), uint256(proof.c1)];

		uint[72] memory input = convertToUint256Array(
			sender, // locker
			msg.sender,
			hPass
		);

		Verifier.Proof memory p = Verifier.Proof({
			a: Pairing.G1Point(a[0], a[1]),
			b: Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]),
			c: Pairing.G1Point(c[0], c[1])
		});

		require(verifier.verifyTx(p, input), "Proof Not Verified");

		if (compareStrings(prizeType, "erc20")) {
			transferERC20(msg.sender, contractAddress, amount);
			emit DropUnlocked(
				lockId,
				sender,
				msg.sender,
				hPass,
				prizeType,
				contractAddress,
				amount,
				expiry
			);
			delete drops[lockId];
		} else if (compareStrings(prizeType, "erc721")) {
			transferERC721(msg.sender, contractAddress, amount);
			emit DropUnlocked(
				lockId,
				sender,
				msg.sender,
				hPass,
				prizeType,
				contractAddress,
				amount,
				expiry
			);
			delete drops[lockId];
		} else if (compareStrings(prizeType, "eth")) {
			transferETH(msg.sender, amount);
			emit DropUnlocked(
				lockId,
				sender,
				msg.sender,
				hPass,
				prizeType,
				contractAddress,
				amount,
				expiry
			);
			delete drops[lockId];
		}
	}

	function unlockExpiredLock(bytes32 lockId) public {
		(
			address sender,
			bytes32 hPass,
			string memory prizeType,
			address contractAddress,
			uint256 amount,
			uint256 expiry
		) = getDropLockById(lockId);

		require(!compareStrings(prizeType, ""), "Drop Doesn't Exist");
		require(block.timestamp >= expiry, "Lock Has Not Expired Yet");
		require(msg.sender == sender, "Lock Doesn't Belong To You");

		if (compareStrings(prizeType, "erc20")) {
			transferERC20(msg.sender, contractAddress, amount);
			emit DropUnlocked(
				lockId,
				sender,
				msg.sender,
				hPass,
				prizeType,
				contractAddress,
				amount,
				expiry
			);
			delete drops[lockId];
		} else if (compareStrings(prizeType, "erc721")) {
			transferERC721(msg.sender, contractAddress, amount);
			emit DropUnlocked(
				lockId,
				sender,
				msg.sender,
				hPass,
				prizeType,
				contractAddress,
				amount,
				expiry
			);
			delete drops[lockId];
		} else if (compareStrings(prizeType, "eth")) {
			transferETH(msg.sender, amount);
			emit DropUnlocked(
				lockId,
				sender,
				msg.sender,
				hPass,
				prizeType,
				contractAddress,
				amount,
				expiry
			);
			delete drops[lockId];
		}
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
