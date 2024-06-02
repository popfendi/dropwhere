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
		bytes32 b1,
		bytes32 b2
	) public pure returns (uint256[104] memory) {
		uint256[104] memory result;

		for (uint256 i = 0; i < 20; i++) {
			result[i] = uint256(uint8(bytes20(addr1)[i]));
			result[i + 20] = uint256(uint8(bytes20(addr2)[i]));
		}

		for (uint256 i = 0; i < 32; i++) {
			result[i + 40] = uint256(uint8(b1[i]));
			result[i + 72] = uint256(uint8(b2[i]));
		}

		return result;
	}

	function testVerifyTxPass() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 passHash = keccak256("password111");
		bytes32 lockHash = keccak256(abi.encodePacked(passHash, locker));
		bytes32 unlockHash = keccak256(abi.encodePacked(passHash, unlocker));

		uint[2] memory a = [
			uint256(
				0x2d6cf7f6b5d48172314a9709397f56dbc44310b9b656bd68591dcf6a3d2032e5
			),
			uint256(
				0x159632bb7825ddcab8e1bc40835bc8beb1f3f54c6cf1266f84b7061e396cad8d
			)
		];
		uint[2][2] memory b = [
			[
				uint256(
					0x2e269c207af3d448150e0703997a4818c48455dc8f1265b49f66e496fa09259b
				),
				uint256(
					0x0e6b77d03d593c70b764c82133f126f0d70619a25555b5bcff7f95a672f7f182
				)
			],
			[
				uint256(
					0x1a51b47b3b02743fc7886a128a6a028569dc530351b50990ac7c8f6a9c3c1e49
				),
				uint256(
					0x00478978e76b8ce2d49017421c720ddbc0e6fa44f62de29c6acf9ae17fe64f60
				)
			]
		];
		uint[2] memory c = [
			uint256(
				0x116803c0fc3084a4098b745e5c61bed686d05a1c831f0082b8add58045307fbf
			),
			uint256(
				0x108e848c35b7bfa27263d51ab227e72afc2d1484d69600b938337f2986403e41
			)
		];

		uint[104] memory input = convertToUint256Array(
			locker,
			unlocker,
			unlockHash,
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

	function testVerifyTxFail() public {
		address locker = 0x0a2E421B230AB473619D9E2B4b4fBbC1e2c2C5d3;
		address unlocker = 0x2465F36F0Cf94d4bea77A6f1D775984274461e36;
		bytes32 passHash = keccak256("password111");
		bytes32 wrongPassHash = keccak256("wrongPassWord");
		bytes32 lockHash = keccak256(abi.encodePacked(passHash, locker));
		bytes32 unlockHash = keccak256(
			abi.encodePacked(wrongPassHash, unlocker)
		);

		uint[2] memory a = [
			uint256(
				0x2c42fb40f85226fec44ee8efb597597f7ad1e6e5a36c52d5b89882dcea6b6a15
			),
			uint256(
				0x04a79388ab867f55c02c511b15720fc4f75f3086cc2d89d8fe5561bd4ce9cbf9
			)
		];
		uint[2][2] memory b = [
			[
				uint256(
					0x23bc47678acf5f6d96174fc61e0b01752aa12dcf1fc05cd2c0d95000002b2e1f
				),
				uint256(
					0x2c05d0f1151fa00775f7a5b4c6b1d4174d6ac66047b5a1f4dc0bed490a0d1113
				)
			],
			[
				uint256(
					0x09ee6a245d26cd19af0602076b746f663f915f83b9027fb0d5f6d74db06df0d6
				),
				uint256(
					0x1e45388bc2f3eb7c099d6d3b7b7ca722e80697ba79ab8e837c4d761c00ed21ac
				)
			]
		];
		uint[2] memory c = [
			uint256(
				0x004419a0465d9b994efc7c6a09ac4303c108146ee1ee0ba4ca73c5a1ffdc8ccd
			),
			uint256(
				0x14472fc146c5124305ce0245e628d5eb2a05abaa2fb338f64ab6ce671af99a57
			)
		];

		uint[104] memory input = convertToUint256Array(
			locker,
			unlocker,
			unlockHash,
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
