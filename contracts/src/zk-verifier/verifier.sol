// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
	struct G1Point {
		uint X;
		uint Y;
	}
	// Encoding of field elements is: X[0] * z + X[1]
	struct G2Point {
		uint[2] X;
		uint[2] Y;
	}
	/// @return the generator of G1
	function P1() internal pure returns (G1Point memory) {
		return G1Point(1, 2);
	}
	/// @return the generator of G2
	function P2() internal pure returns (G2Point memory) {
		return
			G2Point(
				[
					10857046999023057135944570762232829481370756359578518086990519993285655852781,
					11559732032986387107991004021392285783925812861821192530917403151452391805634
				],
				[
					8495653923123431417604973247489272438418190587263600148770280649306958101930,
					4082367875863433681332203403145435568316851327593401208105741076214120093531
				]
			);
	}
	/// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
	function negate(G1Point memory p) internal pure returns (G1Point memory) {
		// The prime q in the base field F_q for G1
		uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
		if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
		return G1Point(p.X, q - (p.Y % q));
	}
	/// @return r the sum of two points of G1
	function addition(
		G1Point memory p1,
		G1Point memory p2
	) internal view returns (G1Point memory r) {
		uint[4] memory input;
		input[0] = p1.X;
		input[1] = p1.Y;
		input[2] = p2.X;
		input[3] = p2.Y;
		bool success;
		assembly {
			success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
			// Use "invalid" to make gas estimation work
			switch success
			case 0 {
				invalid()
			}
		}
		require(success);
	}

	/// @return r the product of a point on G1 and a scalar, i.e.
	/// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
	function scalar_mul(
		G1Point memory p,
		uint s
	) internal view returns (G1Point memory r) {
		uint[3] memory input;
		input[0] = p.X;
		input[1] = p.Y;
		input[2] = s;
		bool success;
		assembly {
			success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
			// Use "invalid" to make gas estimation work
			switch success
			case 0 {
				invalid()
			}
		}
		require(success);
	}
	/// @return the result of computing the pairing check
	/// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
	/// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
	/// return true.
	function pairing(
		G1Point[] memory p1,
		G2Point[] memory p2
	) internal view returns (bool) {
		require(p1.length == p2.length);
		uint elements = p1.length;
		uint inputSize = elements * 6;
		uint[] memory input = new uint[](inputSize);
		for (uint i = 0; i < elements; i++) {
			input[i * 6 + 0] = p1[i].X;
			input[i * 6 + 1] = p1[i].Y;
			input[i * 6 + 2] = p2[i].X[1];
			input[i * 6 + 3] = p2[i].X[0];
			input[i * 6 + 4] = p2[i].Y[1];
			input[i * 6 + 5] = p2[i].Y[0];
		}
		uint[1] memory out;
		bool success;
		assembly {
			success := staticcall(
				sub(gas(), 2000),
				8,
				add(input, 0x20),
				mul(inputSize, 0x20),
				out,
				0x20
			)
			// Use "invalid" to make gas estimation work
			switch success
			case 0 {
				invalid()
			}
		}
		require(success);
		return out[0] != 0;
	}
	/// Convenience method for a pairing check for two pairs.
	function pairingProd2(
		G1Point memory a1,
		G2Point memory a2,
		G1Point memory b1,
		G2Point memory b2
	) internal view returns (bool) {
		G1Point[] memory p1 = new G1Point[](2);
		G2Point[] memory p2 = new G2Point[](2);
		p1[0] = a1;
		p1[1] = b1;
		p2[0] = a2;
		p2[1] = b2;
		return pairing(p1, p2);
	}
	/// Convenience method for a pairing check for three pairs.
	function pairingProd3(
		G1Point memory a1,
		G2Point memory a2,
		G1Point memory b1,
		G2Point memory b2,
		G1Point memory c1,
		G2Point memory c2
	) internal view returns (bool) {
		G1Point[] memory p1 = new G1Point[](3);
		G2Point[] memory p2 = new G2Point[](3);
		p1[0] = a1;
		p1[1] = b1;
		p1[2] = c1;
		p2[0] = a2;
		p2[1] = b2;
		p2[2] = c2;
		return pairing(p1, p2);
	}
	/// Convenience method for a pairing check for four pairs.
	function pairingProd4(
		G1Point memory a1,
		G2Point memory a2,
		G1Point memory b1,
		G2Point memory b2,
		G1Point memory c1,
		G2Point memory c2,
		G1Point memory d1,
		G2Point memory d2
	) internal view returns (bool) {
		G1Point[] memory p1 = new G1Point[](4);
		G2Point[] memory p2 = new G2Point[](4);
		p1[0] = a1;
		p1[1] = b1;
		p1[2] = c1;
		p1[3] = d1;
		p2[0] = a2;
		p2[1] = b2;
		p2[2] = c2;
		p2[3] = d2;
		return pairing(p1, p2);
	}
}

contract Verifier {
	using Pairing for *;
	struct VerifyingKey {
		Pairing.G1Point alpha;
		Pairing.G2Point beta;
		Pairing.G2Point gamma;
		Pairing.G2Point delta;
		Pairing.G1Point[] gamma_abc;
	}
	struct Proof {
		Pairing.G1Point a;
		Pairing.G2Point b;
		Pairing.G1Point c;
	}
	function verifyingKey() internal pure returns (VerifyingKey memory vk) {
		vk.alpha = Pairing.G1Point(
			uint256(
				0x2d14693750b6850dc8dd763d3b85c20ec11d6db2f11859c20e09fe4ad2626fc6
			),
			uint256(
				0x0e77b9e241797fa238654d04aac753b87ee1205c62cdf296d64825eac71f53e9
			)
		);
		vk.beta = Pairing.G2Point(
			[
				uint256(
					0x2695dc4f2e5d59eff7a363df4a6044ba67d87e94f724065725f97ed24897a96b
				),
				uint256(
					0x2d5427208ff11394f91a85b9907521a9e25450feed4479768d1441d8121c6354
				)
			],
			[
				uint256(
					0x2809e8068357c18d56ab2b035e5dfb2e07a59b2ce679ba9e2211b937bd32e596
				),
				uint256(
					0x1cc7f891859fddcb53724a053f00a864a593d198b7a282dde37523ff888aabb2
				)
			]
		);
		vk.gamma = Pairing.G2Point(
			[
				uint256(
					0x0b6a0e42617ef40ade5d6884aaaf596bde2859e783f08025ee861959c10af6ad
				),
				uint256(
					0x14bde04757f5e00a520d6296fe3930381c4f845638ebc21b0aecd41508c760ca
				)
			],
			[
				uint256(
					0x13f8167b7dd7a34f6cd0d6d5b3a941ea0564f93e9af7946469e9f2b0071ad6e3
				),
				uint256(
					0x18afa28acd471176939940d0f63ee041f86aff02d530eb7d066243218078516e
				)
			]
		);
		vk.delta = Pairing.G2Point(
			[
				uint256(
					0x01ed4684f857a12fa8dfcc66056729a4dc4ab82c4e3cdd192d9f43c8f617e8ed
				),
				uint256(
					0x05b9e2d4d28c0e9d591909d5ecbfa8e1f4bec900b476315d40fa828f41dbbce1
				)
			],
			[
				uint256(
					0x0d269fea0c8a4ced5f59b32f4bc0a41102404c0745797fa7b128440eb018573a
				),
				uint256(
					0x1188a4e75ada0f2ee91ae3692d3b41dc8f6d51c602144a74d7a0e69eb17155b4
				)
			]
		);
		vk.gamma_abc = new Pairing.G1Point[](34);
		vk.gamma_abc[0] = Pairing.G1Point(
			uint256(
				0x26b0071642b2c8739e2f86ade1a582099f34027a2eb3efc760cb1e4f46cbdbe3
			),
			uint256(
				0x218010a9dca17a02416279b23cd1db9f775ce87ddbbaf5509cd6950f48dea2ea
			)
		);
		vk.gamma_abc[1] = Pairing.G1Point(
			uint256(
				0x160058fed6497fc464a388b31fe6ac2cfe3f82d4b96961d3c545779e07813a66
			),
			uint256(
				0x0ef255d998aab0370e82469222289eebd943afd0cd4b4716c7e94260f4787add
			)
		);
		vk.gamma_abc[2] = Pairing.G1Point(
			uint256(
				0x1f22bb3f2399aa185e63bce125c808c33fa819314c9780ad47b052da74942ce7
			),
			uint256(
				0x2d56fa3db5eae23d83075cd1ef8fd270784813a62dc2c7d08e4bdfc6d530d217
			)
		);
		vk.gamma_abc[3] = Pairing.G1Point(
			uint256(
				0x1202a44432433aff76a4c8c8c02ba2066e56820c31451c2c6713037599829783
			),
			uint256(
				0x219bcaeafa6b5a18a13111d95299611131e5933187bb4091702faa1c1c713631
			)
		);
		vk.gamma_abc[4] = Pairing.G1Point(
			uint256(
				0x2a15c1e563231192a1cb2225e858b83eb87b4f3ff72848b48c25327901a02718
			),
			uint256(
				0x14753aa9fdefc5a521289e4be2fb1355d97968debc5670d64495752b1947d7fc
			)
		);
		vk.gamma_abc[5] = Pairing.G1Point(
			uint256(
				0x25b3c858f5a2f5a71240d53b78cd6d98ded6adae58a51fdf8d3c7aea73e83bb8
			),
			uint256(
				0x0976fbaa47a9e681221b3864f27b913ddd2e40584f941c3244c6d7d25d420c95
			)
		);
		vk.gamma_abc[6] = Pairing.G1Point(
			uint256(
				0x2d078da3a342475a0ccfa469db09e9aa590f3bc29101d11c65781f45d1723fed
			),
			uint256(
				0x20f0243d5ef5a8c350c9a9575ba0ce460860b6f2196e586e1b7b660bc74b6463
			)
		);
		vk.gamma_abc[7] = Pairing.G1Point(
			uint256(
				0x0b2c4b603d1b2116c920fd2c0bd31e057fc68310128cab5627f0032329a8b387
			),
			uint256(
				0x13f9bbd9a9232a4c8f358b818f5712f5faa5256aba1eac64c8fbb83216be0f7c
			)
		);
		vk.gamma_abc[8] = Pairing.G1Point(
			uint256(
				0x0fe04bc4ef1de407760bd2686f97a283849c67c86d4f0f0f66781aadb61d51ba
			),
			uint256(
				0x1fcd05fabed044ad6ab1f1f21163505da39e03927864ccfe8e2a20b7907f63a2
			)
		);
		vk.gamma_abc[9] = Pairing.G1Point(
			uint256(
				0x0f9be1cd15cf6e8e7ac0415d88f6537786884351647642501e61a0aa3f73aed1
			),
			uint256(
				0x0767bb8f12c8d3626e64b9bac83f557821a1f2b91fc88d3660d5786fff2e2736
			)
		);
		vk.gamma_abc[10] = Pairing.G1Point(
			uint256(
				0x2d1a2f8a039889c565aeeb3d69c4cb05b682abc1077c127bc1a33708743451be
			),
			uint256(
				0x0f4efd1f1f7c6c89b4905b9ae46302d74200cf2a59102108876dc4d91ad21ea9
			)
		);
		vk.gamma_abc[11] = Pairing.G1Point(
			uint256(
				0x1be1a6a9f23e0e1b83380c2b05528b18f1260266743c7ecfd5a53789e4af18a3
			),
			uint256(
				0x1accc6c03dea16a2f4fbd74b8938aa59fd73150a855e52516f2fb27817b8d431
			)
		);
		vk.gamma_abc[12] = Pairing.G1Point(
			uint256(
				0x02d2d60aa9c10dbec2cdee5da1414ebfc72b5a993c8bda8c26f1e72a3cd32f04
			),
			uint256(
				0x2d1b231cb872e618c20bdbc8fd4418bba74118ccf6176948ce01d4abadd6effb
			)
		);
		vk.gamma_abc[13] = Pairing.G1Point(
			uint256(
				0x1b0f090998f167b0c2d44358f36b8f70ec3fb2d27c4a7874431793a4faa823a9
			),
			uint256(
				0x0d4b96f9229526a7f2917d931432c4febb8cfe204636aed7aeddca448b43abb5
			)
		);
		vk.gamma_abc[14] = Pairing.G1Point(
			uint256(
				0x10e0725a02d0296c6fe3744ddae3917d48fa4aef3a5d6328145a6bbdfd4dac66
			),
			uint256(
				0x00d2b5a532a066540654ba405ecf723d69d9077c57b7cc42fc1716c0d3b603a2
			)
		);
		vk.gamma_abc[15] = Pairing.G1Point(
			uint256(
				0x160fd729c18c18633f9fc34e6d4137aa740a308a6cff6d3d2f9ee186305c39aa
			),
			uint256(
				0x0492ba596e0c97422be24312224f732717799698709c400bc6b008a2ea54990f
			)
		);
		vk.gamma_abc[16] = Pairing.G1Point(
			uint256(
				0x0c83d192d162757ce0c221d2a7e003faf462c4d7a25f74508ecf423e34a3cfc2
			),
			uint256(
				0x1437101c5e6018edaf3903fabd1be2160cdc595ea9be0611e5a2e8d8f3605bcf
			)
		);
		vk.gamma_abc[17] = Pairing.G1Point(
			uint256(
				0x0b00fd86efd92b7d0ac7d4063ff3bb5090694fa5a0b4564b4a607ea44c63d157
			),
			uint256(
				0x084fb7e6717656fe89aa9ebcc6399b295fc1870e3a4a3b64ca7b58426b57fc74
			)
		);
		vk.gamma_abc[18] = Pairing.G1Point(
			uint256(
				0x100e4aecae78dd36253e8f830f3eb84e2e0d3ac9bd8036db452853385e6c1bed
			),
			uint256(
				0x0266d9f582a942e268821971f025ea3edda181b6d22cc628f4f8265de35a0f61
			)
		);
		vk.gamma_abc[19] = Pairing.G1Point(
			uint256(
				0x0f71beef97f573b302903df910afb6bd774153e1bd3e5e982041cc40e2888530
			),
			uint256(
				0x08d7a05b96bfbf35b884c399108f2a0999212e87dd025a9e006be07bdf089c43
			)
		);
		vk.gamma_abc[20] = Pairing.G1Point(
			uint256(
				0x1640821a5b2e8585a348feb68bdbb4bad94a8b5255ae66798f97f5aff24a4aca
			),
			uint256(
				0x1c6e55396bbf2fd7135344bbd0ee7bd9c3f44dcbbef4187a3622ffa55e60caf1
			)
		);
		vk.gamma_abc[21] = Pairing.G1Point(
			uint256(
				0x255c099b63e70fdaea18a3fe1fab7b55508c23e96696242a3d8d78fceb1a455f
			),
			uint256(
				0x082b045a050679a49147bb9386d089fb4207c71ddd66ea5ab6b259298bac46d5
			)
		);
		vk.gamma_abc[22] = Pairing.G1Point(
			uint256(
				0x1a7cb9794045c7bb1e0454e755a6221f667b9d9904015f0dd66ce041891e6289
			),
			uint256(
				0x21fa17c37e705fb0acfc6874460d8cc30ba71505ff23564f3ff044ca81e7cda0
			)
		);
		vk.gamma_abc[23] = Pairing.G1Point(
			uint256(
				0x087677d1fc57bb18df8ece9152165ae32a1d2281ee3b777370a0105810ac900a
			),
			uint256(
				0x2c0ceb70118e0851c9bd93748e5c31b9ff0f47dbeaa89056ee3d7fdec04e57d9
			)
		);
		vk.gamma_abc[24] = Pairing.G1Point(
			uint256(
				0x128838200dc23feba003487bb25340dac1ed85135a5fbe910b743638a6f652e3
			),
			uint256(
				0x23be95e32229f75c37b5747b22782de7eb14681bfdca8119a9829b6ea611ef56
			)
		);
		vk.gamma_abc[25] = Pairing.G1Point(
			uint256(
				0x0ee05721acd30f875b590d6177012f2e96512757f3b6706ce2d023b16bf136be
			),
			uint256(
				0x191e4c5b1c4dd5c88f43277fade4d3007d30f7c2ec2e55b771b24453cffe7f52
			)
		);
		vk.gamma_abc[26] = Pairing.G1Point(
			uint256(
				0x1c4e4fdae5febf61100f25b85d6716e4852b5de76ddf8c2fcd48e3264b39a6d0
			),
			uint256(
				0x0495dfa7318c6b75f163016953bc1c5a025f36d1b922c8232640756669ef1513
			)
		);
		vk.gamma_abc[27] = Pairing.G1Point(
			uint256(
				0x24027c3396b8f0e55d17d9d755ddd7f4edd35a3643b904c7ad9a514f45b707e9
			),
			uint256(
				0x24d934d005ebfdeb2be3eced284f730aad74124a0d45f279b340b0d2a63f1cba
			)
		);
		vk.gamma_abc[28] = Pairing.G1Point(
			uint256(
				0x2044a07feb53ef85505d00f1420bacba8f530caff032e9b7b6f5726c7e25e0ca
			),
			uint256(
				0x01dfacd2c2c69fc2031fce41ed59388a41c0033ac86663cf074ebb1c69fbec1e
			)
		);
		vk.gamma_abc[29] = Pairing.G1Point(
			uint256(
				0x14037d900e8a59b0761552358c2cb089349736d1a1a2932ccbdad74a1f7b158f
			),
			uint256(
				0x189e6ba5c77d93ead1f7ad731225c0b7ad7b6e0f63a77749bb7427f4f1e689ec
			)
		);
		vk.gamma_abc[30] = Pairing.G1Point(
			uint256(
				0x1e958e734bcbe33e82b45da8b52ddb3938a34475f1f727897cba9d40ed67d029
			),
			uint256(
				0x111296cb1d13b9e036b8078b0c59fa07fb0397972e1ba8f35924a74a1c6ba480
			)
		);
		vk.gamma_abc[31] = Pairing.G1Point(
			uint256(
				0x050cf13280adbd1b456af9026a970775c5e16c7c2d0e49ae534b15000d447d57
			),
			uint256(
				0x00954e5828ab58c409ab1fd02ddfe9f4b631902a295060166190ec6f21e3d47d
			)
		);
		vk.gamma_abc[32] = Pairing.G1Point(
			uint256(
				0x26bcbaf13201ddc7f43da6be5d675bc3cd2a3b1e69795429a6bf93cd4421efe5
			),
			uint256(
				0x02224e4c3ae514fc2746a74940c1016b1dba8e00030b72d194ea5bc9fc79e75c
			)
		);
		vk.gamma_abc[33] = Pairing.G1Point(
			uint256(
				0x005f053f5354c8b654e5437ced36e5d30648ca093cc7b60075800c39768aea34
			),
			uint256(
				0x12d492e97da4cd304f67d690db9e6f86440557938bbfead37a25cc780698b7ae
			)
		);
	}
	function verify(
		uint[] memory input,
		Proof memory proof
	) internal view returns (uint) {
		uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
		VerifyingKey memory vk = verifyingKey();
		require(input.length + 1 == vk.gamma_abc.length);
		// Compute the linear combination vk_x
		Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
		for (uint i = 0; i < input.length; i++) {
			require(input[i] < snark_scalar_field);
			vk_x = Pairing.addition(
				vk_x,
				Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i])
			);
		}
		vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
		if (
			!Pairing.pairingProd4(
				proof.a,
				proof.b,
				Pairing.negate(vk_x),
				vk.gamma,
				Pairing.negate(proof.c),
				vk.delta,
				Pairing.negate(vk.alpha),
				vk.beta
			)
		) return 1;
		return 0;
	}
	function verifyTx(
		Proof memory proof,
		uint[33] memory input
	) public view returns (bool r) {
		uint[] memory inputValues = new uint[](33);

		for (uint i = 0; i < input.length; i++) {
			inputValues[i] = input[i];
		}
		if (verify(inputValues, proof) == 0) {
			return true;
		} else {
			return false;
		}
	}
}
