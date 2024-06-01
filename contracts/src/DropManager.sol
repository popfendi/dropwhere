// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Verifier } from "./zk-verifier/verifier.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "forge-std/console.sol"; //REMOVE AFTER TESTING

contract DropManager {
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
}
