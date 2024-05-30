// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { DropManager } from "../src/DropManager.sol";

contract ManagerTest is Test {
	DropManager dm;

	function setUp() public {
		dm = new DropManager();
	}

	function test_tileKey() public {
		int256 lat = int256(-120.0001 * 1000000); // 41403380
		int256 lon = int256(21.17403 * 1000000); // 2174030

		bytes32 expectedTileKey = keccak256(
			abi.encodePacked(int256(-1201), int256(211))
		);

		bytes32 actualTileKey = dm.getTileKey(lat, lon);

		assertEq(actualTileKey, expectedTileKey, "Tile key mismatch");
	}
}
