// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { Verifier, Pairing } from "../src/zk-verifier/verifier.sol";

contract VerifierTest is Test {
	Verifier public verifier;

	function setUp() public {
		verifier = new Verifier();
	}

	function convertToUint256Array(
		address addr1,
		address addr2,
		bytes32 b1
	) public pure returns (uint256[72] memory) {
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

	function testVerifyTxPass() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 passHash = keccak256("password111");
		bytes32 lockHash = keccak256(abi.encodePacked(passHash, locker));

		uint[2] memory a = [
			uint256(
				0x2eb10190f4d0b075e7cfb627a74e5a57f3603822998deebb8887a71db55fcc31
			),
			uint256(
				0x2ad948b436acffa75d415f1d91d39cddddcdcb2272f568aaa415a88f9e954d5f
			)
		];
		uint[2][2] memory b = [
			[
				uint256(
					0x2b10e7cd1df73f04323e66a2f8c85b8f54c79f755df3e9806126793f0e30e01e
				),
				uint256(
					0x2555aa5600af3301c0dc687ab657b295fabbd20a231fcf9b122ebc4b6780a29f
				)
			],
			[
				uint256(
					0x11503786b34bbbc71a10f8c6f291ec37dd0c6b25035a68796601e46c00e75563
				),
				uint256(
					0x0bd08799c7ed78f241aa4dc2ec144be65c9a05f1788ee8ee4ff23c990c03e31e
				)
			]
		];
		uint[2] memory c = [
			uint256(
				0x0e863b32d3b7a69ba9d63cb0927d448ee70d6f099ef59c881f78a602a486ed8e
			),
			uint256(
				0x116a86a05c12029cef3dbbc805819cc1577487137526d9d0876c46527005a3b3
			)
		];

		uint[72] memory input = convertToUint256Array(
			locker,
			unlocker,
			lockHash
		);

		Verifier.Proof memory proof = Verifier.Proof({
			a: Pairing.G1Point(a[0], a[1]),
			b: Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]),
			c: Pairing.G1Point(c[0], c[1])
		});

		bool result = verifier.verifyTx(proof, input);

		assertTrue(result);
	}

	// If assertion inside circuit fails a proof won't be generated

	function testVerifyTxFail() public {
		address locker = 0x0A2e421B230aB473619D9e2b4B4fBBc1e2C2C5D4; // trying with different address
		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 passHash = keccak256("password111");
		bytes32 lockHash = keccak256(abi.encodePacked(passHash, locker));

		uint[2] memory a = [
			uint256(
				0x2eb10190f4d0b075e7cfb627a74e5a57f3603822998deebb8887a71db55fcc31
			),
			uint256(
				0x2ad948b436acffa75d415f1d91d39cddddcdcb2272f568aaa415a88f9e954d5f
			)
		];
		uint[2][2] memory b = [
			[
				uint256(
					0x2b10e7cd1df73f04323e66a2f8c85b8f54c79f755df3e9806126793f0e30e01e
				),
				uint256(
					0x2555aa5600af3301c0dc687ab657b295fabbd20a231fcf9b122ebc4b6780a29f
				)
			],
			[
				uint256(
					0x11503786b34bbbc71a10f8c6f291ec37dd0c6b25035a68796601e46c00e75563
				),
				uint256(
					0x0bd08799c7ed78f241aa4dc2ec144be65c9a05f1788ee8ee4ff23c990c03e31e
				)
			]
		];
		uint[2] memory c = [
			uint256(
				0x0e863b32d3b7a69ba9d63cb0927d448ee70d6f099ef59c881f78a602a486ed8e
			),
			uint256(
				0x116a86a05c12029cef3dbbc805819cc1577487137526d9d0876c46527005a3b3
			)
		];

		uint[72] memory input = convertToUint256Array(
			locker,
			unlocker,
			lockHash
		);

		Verifier.Proof memory proof = Verifier.Proof({
			a: Pairing.G1Point(a[0], a[1]),
			b: Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]),
			c: Pairing.G1Point(c[0], c[1])
		});

		bool result = verifier.verifyTx(proof, input);

		assertFalse(result);
	}
}
