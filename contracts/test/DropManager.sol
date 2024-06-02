// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { DropManager } from "../src/DropManager.sol";

contract ManagerTest is Test {
	DropManager dm;

	function setUp() public {
		dm = new DropManager();
	}
}
