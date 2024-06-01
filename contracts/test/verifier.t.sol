// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { Verifier, Pairing } from "../src/zk-verifier/verifier.sol";

contract VerifierTest is Test {
	Verifier public verifier;

	function setUp() public {
		verifier = new Verifier();
	}

	function convertHashToUint256Array(
		bytes32 hash
	) public pure returns (uint256[33] memory) {
		uint256[33] memory result;

		for (uint256 i = 0; i < 32; i++) {
			result[i] = uint256(uint8(hash[i]));
		}

		result[32] = 0;

		return result;
	}

	function testVerifyTxPass() public {
		bytes32 hashed = 0x7e7dbfd841aa32343b03b0e4ec481e6c9bbb71dcafdb49c1a191df2ca09da5ec;

		uint[2] memory a = [
			uint256(
				0x28d2286dffe7907523d6c4fd577bd655a7f3429eae22d667a92e897e397a6e58
			),
			uint256(
				0x138c06a1869e4e92736bdb6a97e3ca2901a38c797b558db3b27497b1c2e6e44e
			)
		];
		uint[2][2] memory b = [
			[
				uint256(
					0x1cbaabd669331b86e3f01568a52ba73110420ceeb851a1397967667f46515701
				),
				uint256(
					0x0654d3bfb61ba697930cc4e7386c39c9d8abdc6247178184e46206395804209c
				)
			],
			[
				uint256(
					0x215811c22a9fd9ca78408f5519c79a8b8584f9b0fde97b9d2c58738ff999a6a4
				),
				uint256(
					0x2087b6b4fd4ae19829bc17511306df17f01a6cbe494707a4ca686fa3f0e5d946
				)
			]
		];
		uint[2] memory c = [
			uint256(
				0x2e81318487b3c82d121c78b9ac31b948c9fcaaaac1e04066a74a5c0156812df7
			),
			uint256(
				0x12e0e156f12d90a9aa92d6f4e1a7845dd927958b3308e7f729c033042bbf7609
			)
		];

		uint[33] memory input = convertHashToUint256Array(hashed);
		input[32] = uint256(
			0x0000000000000000000000000000000000000000000000000000000000000000
		);

		Verifier.Proof memory proof = Verifier.Proof({
			a: Pairing.G1Point(a[0], a[1]),
			b: Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]),
			c: Pairing.G1Point(c[0], c[1])
		});

		bool result = verifier.verifyTx(proof, input);

		assertTrue(result);
	}

	function testVerifyTxFail() public {
		bytes32 hashed = 0x7e7dbfd841aa32343b03b0e4ec481e6c9bbb71dcafdb49c1a191df2ca09da5ec;

		uint[2] memory a = [
			uint256(
				0x060e44ba1b13af5552d78d8884f632e9e5d22405e1e0330980d1f57be26fab86
			),
			uint256(
				0x2c2dded26061859fd863031b0bab8d4589512473044811c3ed13c0c7cea2d228
			)
		];
		uint[2][2] memory b = [
			[
				uint256(
					0x107e39dc4b252e954f12c39e10570c7abcb07d5625963d1d61d9d9cc9551c519
				),
				uint256(
					0x0400ffcd7d8dcf556e0bfb3408b34ce4a5479012fdcfa859d92b4fa0f4433177
				)
			],
			[
				uint256(
					0x21a468a756c075ef247da0350483da285cdef0e66feec9c8ec0af213f2334b6c
				),
				uint256(
					0x121deb7d2d8aec469053b1636b4cd8ae683861ffc4d99653ba617ceb34be0834
				)
			]
		];
		uint[2] memory c = [
			uint256(
				0x1f3b281513fc699e8a2b4e11144ef89c0f608d0530f9ff55fd1749f3935b007e
			),
			uint256(
				0x1518d8c99dcb2fc8bb6a89cfe28f3492e49bc58607297188e83ae4db90d45975
			)
		];

		uint[33] memory input = convertHashToUint256Array(hashed);
		input[32] = uint256(
			0x0000000000000000000000000000000000000000000000000000000000000000
		);

		Verifier.Proof memory proof = Verifier.Proof({
			a: Pairing.G1Point(a[0], a[1]),
			b: Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]),
			c: Pairing.G1Point(c[0], c[1])
		});

		bool result = verifier.verifyTx(proof, input);

		assertTrue(!result);
	}
}
