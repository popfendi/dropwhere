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
				0x1f2197d2765bb7dcd943584a6434a1f69a68d118e2835dd2bfbf6d35ac5895de
			),
			uint256(
				0x1ecbf9175ce7bddb91b42bde6eceae7e2e88553cd1597f121d315e51647c877e
			)
		);
		vk.beta = Pairing.G2Point(
			[
				uint256(
					0x083cbd3ee2ba8c36cde6d3d80f583c6cbbb4a54fdbb1ca7f7e9ae1b85084efb6
				),
				uint256(
					0x262bf22fc485e891a4c6bb745eb010e1b394754a9aae042a221bb3cefcef12bd
				)
			],
			[
				uint256(
					0x2f4afb68525dabfbbf73f6735edbe24843ad12eadfca11404fac17f38a301a15
				),
				uint256(
					0x14fff21145318514c394e52e752accab5982fd8c158cfcb7bef6f0a2c8a835dd
				)
			]
		);
		vk.gamma = Pairing.G2Point(
			[
				uint256(
					0x1f6d2bd8402c4d99a8c287957d241fc51c351f1c80bb49e1f1e1a1607a114f5a
				),
				uint256(
					0x00c9e5d5ee35357e2ab8ce93891e3a7544a31c681827880874ebb06050616901
				)
			],
			[
				uint256(
					0x021f035ea6bbe128657e67a5ee93f1a09ecb8467f0e5820d232b2d081f84d1bf
				),
				uint256(
					0x23147ccd0718b60fac8cad8b096c09b1b14eae135edd2c70678aa9dac4d27314
				)
			]
		);
		vk.delta = Pairing.G2Point(
			[
				uint256(
					0x057aa4f9e468130ada457fc11709d0c59061ee575d753d3a7d0cf6bad57039ed
				),
				uint256(
					0x12bc61cdaa9468616873a35fc8c92fb3ce5ebe6529304385f7a8573569f76bef
				)
			],
			[
				uint256(
					0x068de05993faed2080b20ad6b441dcad90c6ea7416b85fb12c6b28f9279f8a97
				),
				uint256(
					0x2654a51af86a6e22fede2d153193929c1bab0c630935ee58fd37dc36b703563c
				)
			]
		);
		vk.gamma_abc = new Pairing.G1Point[](73);
		vk.gamma_abc[0] = Pairing.G1Point(
			uint256(
				0x04dfa3e74928d0e689f8444d1ce3da9adfbabcd79e8d285b3043f836e47ebee2
			),
			uint256(
				0x18bce798c010631b04df30c18c2951d8f9f2936b0337c1fccf11aaaa3a598985
			)
		);
		vk.gamma_abc[1] = Pairing.G1Point(
			uint256(
				0x0ff9e74232cce7288f35984525aa724434c0a22c61e837c4cdb839be18fadb77
			),
			uint256(
				0x0c885bd182eb901662159710a7d1b9cce37f759ef4defa1e67a3929e3bbec345
			)
		);
		vk.gamma_abc[2] = Pairing.G1Point(
			uint256(
				0x2645509be511f637339af1ec3b2850346e5666071853672a034e7ffb708b535f
			),
			uint256(
				0x208ab06c6fdb80c6de76dd9e5bfac8095fa3256dba760ac86a03ab01cc89d70f
			)
		);
		vk.gamma_abc[3] = Pairing.G1Point(
			uint256(
				0x0b8597c582e3195f33e52ae74f1aa4ccc77f680756538060ebb81dec93107803
			),
			uint256(
				0x1b631c0da25511138e82c73f6abc6d69213466a3c16ccec30041f63e2e9719d9
			)
		);
		vk.gamma_abc[4] = Pairing.G1Point(
			uint256(
				0x147fc71b72a4e333ec3e1420f5af62ea796a6a40c6ead39614b2a4471bbfcdb4
			),
			uint256(
				0x208d530c94553bd4565d658fbdd8b71adaf01d649ae6f8eda051405dc485496f
			)
		);
		vk.gamma_abc[5] = Pairing.G1Point(
			uint256(
				0x24cf1af9da15bceca2fb1013fb16e3e0f39b9ce21d1f4622b9b688134cfbe82a
			),
			uint256(
				0x0a5dbf03b8650f08744a80a97d09909c9d5bcc70c6cbfaf58ce51b5485a07829
			)
		);
		vk.gamma_abc[6] = Pairing.G1Point(
			uint256(
				0x0b5f541b3f00fb57a07b45c3ef5448ec4a81d6038cfda7f736e8759e80980e4e
			),
			uint256(
				0x11637ec0f0d79c9785827b99e2af74084a0da8c5549dd983a9081fedc541c9a3
			)
		);
		vk.gamma_abc[7] = Pairing.G1Point(
			uint256(
				0x205fc68efb43b934d3aea4c8945c2e39c59ea39c0b6ed2a30c7d84f5ae5bfed7
			),
			uint256(
				0x045d724396aa8eb963f4df3ca3af867ef2d71550664596a2e4f438f4ff540941
			)
		);
		vk.gamma_abc[8] = Pairing.G1Point(
			uint256(
				0x138bc681f4262b88c45ef82b29e6a52d4178c13ed37410da410ffb1c2af085fb
			),
			uint256(
				0x1a040552a594dce3c71aae038eed557cc6ecdafee5a8c6989a635b1754682593
			)
		);
		vk.gamma_abc[9] = Pairing.G1Point(
			uint256(
				0x1be61840355d1a70afe3f1a7b9eb73a496f4d371892625947e2dc64efe7f9258
			),
			uint256(
				0x1e0f537b5a986624476346aec58235dcfa171b5770e3bba398436558cfd37b85
			)
		);
		vk.gamma_abc[10] = Pairing.G1Point(
			uint256(
				0x0a3b56ceadce6c98a1d7491a50b610d781076c5f6cddadace0e4639b7d55cc7e
			),
			uint256(
				0x0958c408c61c4184194a8009cbdcfa2f5ad7155cc61e0fc70faae7e5ce53e285
			)
		);
		vk.gamma_abc[11] = Pairing.G1Point(
			uint256(
				0x2207a78fe828dbfbf9b2127f334d895ff37ef87e6dc1d533de1619eb140be6fe
			),
			uint256(
				0x2431d5998b1c0f4216e9130fb22f2f2b4772043c1156a17149de955bad778b19
			)
		);
		vk.gamma_abc[12] = Pairing.G1Point(
			uint256(
				0x2e1d180d22244d43caa61cd4565b08a9ec61a07d1f7ff9c5686a5f21cf5bdabc
			),
			uint256(
				0x1bbb42ed9c9e63f6636e2f1cf3b1414de25839ad9becf573916d29a1d53d9cb7
			)
		);
		vk.gamma_abc[13] = Pairing.G1Point(
			uint256(
				0x13af82a8485fa7050847907af8e2deedc42c10bbb4bad01f18433ebca8299b53
			),
			uint256(
				0x1b3b4305a87abe78efe01d8f4670f92820406c1eefd4bb614c5c29af69722e28
			)
		);
		vk.gamma_abc[14] = Pairing.G1Point(
			uint256(
				0x07971e2964906dd843b87daf21924aa9e7175450f6c88b314dd8ad30ae67d30c
			),
			uint256(
				0x1f6b6932dc8084638da2dffe98e82770c43e6700b722dbb225cda47e14f09b98
			)
		);
		vk.gamma_abc[15] = Pairing.G1Point(
			uint256(
				0x1422f5f60e044f771de669a999c21bd97b4a7160e02d5f9c05caf9c637057ecd
			),
			uint256(
				0x1da3320433bcd8bdc7adf9f7b7f0d2449bc44ec0ebd43414d5b0a9b4d23ba503
			)
		);
		vk.gamma_abc[16] = Pairing.G1Point(
			uint256(
				0x2999d6b2e946424d9b0a7e963968272d306bb05a973d05bca5b05a28b8c9a479
			),
			uint256(
				0x004af505e8c711a0f8c718bfde3be3b64c926f0f63c2745d77d39477760e407e
			)
		);
		vk.gamma_abc[17] = Pairing.G1Point(
			uint256(
				0x0070da8c580a5e9fd0abe8a7faa2bd6731a580a9a4b1dda945bb1988da5d78ed
			),
			uint256(
				0x26df5b0ff3a3e81f3afece2445a8cb6aa260a1a1f0ed90eaf7e0803b35c26f8f
			)
		);
		vk.gamma_abc[18] = Pairing.G1Point(
			uint256(
				0x0cab155788b37b81a40f72b91e3cd7789c8a03d89daa2f214efc692d1cd5e395
			),
			uint256(
				0x0be2ba421e49562c8ddc85529a64bbb83060b1c111dea79e25d0794c76cd9aa5
			)
		);
		vk.gamma_abc[19] = Pairing.G1Point(
			uint256(
				0x0fe5aa887204080b6cc2aac473eea9d393aa6d9eff8930a342adca614c9b5fe6
			),
			uint256(
				0x1b86e93201fa0534f9b261224132f0c83853dfcec07fb4228bfa6174fd568d40
			)
		);
		vk.gamma_abc[20] = Pairing.G1Point(
			uint256(
				0x162f019493127a854d5d6293b0e4ecb2d603c4e9e4c6559bfa8f3ffa4ed3e879
			),
			uint256(
				0x01111ecb283755ea0896d6a75eb812b12821f738068e207f084ca73577bb5daf
			)
		);
		vk.gamma_abc[21] = Pairing.G1Point(
			uint256(
				0x0bfa0d886359443bee2404106edc1d256a118bf1329f923030f06d462e1467ef
			),
			uint256(
				0x209cc5c4df64715216f05a71c69dd0bf8d8932282dd2372a1883559470cabd44
			)
		);
		vk.gamma_abc[22] = Pairing.G1Point(
			uint256(
				0x1f5739f2acca3264c2309fb8e819a82cbe375245118f4bb9df4aac51f14fa1f6
			),
			uint256(
				0x302c51c2a066c0d58facf2d8ea13c992c3d4d1a9d78fff011b65f26e9f0a2574
			)
		);
		vk.gamma_abc[23] = Pairing.G1Point(
			uint256(
				0x1e9a2b1f68f9d5c328f8d66007301a120203373727f460e821deafe7455971ec
			),
			uint256(
				0x119157870f58b57acf7a6418a4af7cd51ba93f0a801af5f08da7e65c687d734c
			)
		);
		vk.gamma_abc[24] = Pairing.G1Point(
			uint256(
				0x12fa9e7d61017cc85ba8a6ea304c75936e8c9dbacc870d254e756e194d960b4e
			),
			uint256(
				0x018774bd01a5574fb7bfd53625e37620c9e6bfd8ae7703a8c9d59dd12a5ddb55
			)
		);
		vk.gamma_abc[25] = Pairing.G1Point(
			uint256(
				0x14e13f1802277d8f9e949cc19fd43573499127ad1356de2e8dfc7419332e75b0
			),
			uint256(
				0x1a639df183d654fb32aa40849172944eb8a801abc7acd977c63b4c9a59657b29
			)
		);
		vk.gamma_abc[26] = Pairing.G1Point(
			uint256(
				0x106cdf0e0c571e90caa80ecd35703d4355cbc20b5b8f4acd9b17f400b3d32ce7
			),
			uint256(
				0x1c1682144c26b25ce5913342e375752e24473d88001bba165e022ccf9db35028
			)
		);
		vk.gamma_abc[27] = Pairing.G1Point(
			uint256(
				0x26f7e547003a1262745a17f77c785c020758c8c94e3ce1566f52eeadfaf81bbb
			),
			uint256(
				0x0d79f96d01ad5cf566fb41bb2bf8ca973c4ec0a7c742def0154b929f474a8d0f
			)
		);
		vk.gamma_abc[28] = Pairing.G1Point(
			uint256(
				0x1a7cbd05f15a49110d2378da8fa73e417ae4bbbbe3d994f02c900d8009a60ac6
			),
			uint256(
				0x2a15f2727a82ceb17c7cbf545b598a8050124eceffbdd1a08f91ddf75553345e
			)
		);
		vk.gamma_abc[29] = Pairing.G1Point(
			uint256(
				0x14184453307f267685d7382c0aae185820c30aebf6442aa7fea16d102e75edbf
			),
			uint256(
				0x0931837de263ac771cdad313f0a708e70d3d02db3bc1fdcd133910ce271e239e
			)
		);
		vk.gamma_abc[30] = Pairing.G1Point(
			uint256(
				0x033188f84bf8483cc253e9b7113fd58122edce72f323a52dfa83e5e063c0c02e
			),
			uint256(
				0x006e58fe3cc44aac1f529086dc2e398a01a1237664d634958b3ec5e5faf83b33
			)
		);
		vk.gamma_abc[31] = Pairing.G1Point(
			uint256(
				0x050b419d0537a95ec6e0fbd14312239df38f2c58779450ca68cac50be7b2f572
			),
			uint256(
				0x03646bd1c0f5a7eee5c3f0a6339c157de73202cf59e4e5e3ad36095378da421a
			)
		);
		vk.gamma_abc[32] = Pairing.G1Point(
			uint256(
				0x10835f378a92ed76a32d81c47e7aedc3fbdc421fad5ead89cb3140f889091e27
			),
			uint256(
				0x1019623d06ef51022fdd80ec56ab9d4e7f9ed82e116d9fb8e36cabc8b03a27a8
			)
		);
		vk.gamma_abc[33] = Pairing.G1Point(
			uint256(
				0x1ec0dc4d12da67c9edca39dd3dca2b762406c0db7512a71c06fd3a58d15285a7
			),
			uint256(
				0x227bbd98d96776f5e829cb54ffaaf40268e308b1c8eb13c8fd726ee4b67c18fa
			)
		);
		vk.gamma_abc[34] = Pairing.G1Point(
			uint256(
				0x26ec0410163abdcc73826df0ecd4c22c38fb20cf71611871acfa6e6995e7961e
			),
			uint256(
				0x2870b8af8827325b2ed501b9aa5fef26063d27f5623016b1315c9348f8c29a07
			)
		);
		vk.gamma_abc[35] = Pairing.G1Point(
			uint256(
				0x129cd7bc9a6e807ddf16ddcea4bd025ca906681e28ee96cac7c52c6f9a939879
			),
			uint256(
				0x0837d291151644ea4567b3f91d7c666a14726a28cd19c8657290f68ecbcfbcc0
			)
		);
		vk.gamma_abc[36] = Pairing.G1Point(
			uint256(
				0x06927b30fd94b1af253a60cf6028fd00206f92eed3d5b9789efdcc892d161d3b
			),
			uint256(
				0x15c21b8ea105e17d2cea484c57f7fe530fade7fcf1249dbd27f72afebddc6e2d
			)
		);
		vk.gamma_abc[37] = Pairing.G1Point(
			uint256(
				0x2884d33c60218bc285b1da9b4b744d802724f415b731af70ff486e3ddf258df4
			),
			uint256(
				0x2d2eb15fd73811fc6665696c3a6a1956aff805a8c59161fe44084d8adf68af43
			)
		);
		vk.gamma_abc[38] = Pairing.G1Point(
			uint256(
				0x04a9f4addba18c13394993615eafd64df4feb8bcfa1d1323c423c3593a0960b5
			),
			uint256(
				0x0421871ba3c18e7839f9751cf49d2d5867c7e42267a1b0daabf5340aae215bf7
			)
		);
		vk.gamma_abc[39] = Pairing.G1Point(
			uint256(
				0x02e950f64fbc592ca9c16f4edd9fd7293b34717548dcd11b3058fe2cd8f0b263
			),
			uint256(
				0x146e528b899464df1f57457abf8c0034f80daebb733618b2e96962b1155b277e
			)
		);
		vk.gamma_abc[40] = Pairing.G1Point(
			uint256(
				0x1eff8cc7ab6837d73372d1a805feebc78fd26fb276c06a0f24b12aedc9116a08
			),
			uint256(
				0x2e941674570938c315c48fd8245c6749d0b0e3fd6ca51b7ab91e680f54a98326
			)
		);
		vk.gamma_abc[41] = Pairing.G1Point(
			uint256(
				0x0cec423fa34a7dd32ca175341eea036f5aceb024e11a446fa8ff5b2da37698c5
			),
			uint256(
				0x14557e05f9786460dfd1d5418aab5d9de553e74585db2d6c540762e2c9caca2e
			)
		);
		vk.gamma_abc[42] = Pairing.G1Point(
			uint256(
				0x02d5f208b6b247ba37d09b5660889ac0c9d296f8d7b988a797eff4699482aecc
			),
			uint256(
				0x28512190984354f1e40e00f03c1486a7e290a225047322a33852b1041c3163fc
			)
		);
		vk.gamma_abc[43] = Pairing.G1Point(
			uint256(
				0x12876223a61e6890967c21c6a9f4e49367369bf79c2aedf374b72426971a536e
			),
			uint256(
				0x2ad0d7c474d60bba1dd444305ff68d78145bc7707e3ec3b7437faf33b4f5776b
			)
		);
		vk.gamma_abc[44] = Pairing.G1Point(
			uint256(
				0x124b656b9c7a723617663f893835ce9d08acc60174f5e9c234fab51e659e5e59
			),
			uint256(
				0x0f769863306c75b9981d53b040d027698a385fc4d0b89ef3e16112bf1c50e70e
			)
		);
		vk.gamma_abc[45] = Pairing.G1Point(
			uint256(
				0x0b225478861b862e6bb30e9d79c758691fc76d47b20faf7f6eebcdd7ee9f03f0
			),
			uint256(
				0x0ec44ed2761457bf945d98af72aab12ad2a3e8f6c07830eee0c3c05c5cd3c36f
			)
		);
		vk.gamma_abc[46] = Pairing.G1Point(
			uint256(
				0x279725bbe4dbed4685bdd9a0a696df7d26a33377ec02449623b557d94ffe6add
			),
			uint256(
				0x1fcbbc6c11bcb0b7f51903078ba3f3e95d84bf9cfe3fa94b15c98e8032440864
			)
		);
		vk.gamma_abc[47] = Pairing.G1Point(
			uint256(
				0x125281ff1e57c929f6f9075bf5d41c249eeb1571ef443082277e9debedad2eb6
			),
			uint256(
				0x02f59978fc43a3201eacc436e7270ddebf558d10dd2eef9696cf3c3088276633
			)
		);
		vk.gamma_abc[48] = Pairing.G1Point(
			uint256(
				0x2ab514b466dfee209da1d725e30bf1590506cb8f3c864a2dbb8bd2a47a52054f
			),
			uint256(
				0x289c1a1ac907dd6ae1ebdf5fbfc4eceb8c3290a9920fb80a85353107b5eec2dc
			)
		);
		vk.gamma_abc[49] = Pairing.G1Point(
			uint256(
				0x22282a018f555316ce9d84a404ca77c73d6a06e6a80b552e076956aa4250675c
			),
			uint256(
				0x0b4a79980a2db0cb3367f2b060914db99e2831b8676f27ed693f98aec1738672
			)
		);
		vk.gamma_abc[50] = Pairing.G1Point(
			uint256(
				0x2d6eca1fcd6ac164eb0ae91c20323469e62beebbc8470c27b47bcf859b083695
			),
			uint256(
				0x0e2008e50920c9a4a4a75d4dd5581d178e1d9217a18d53a79a0105a6b8f5f8c9
			)
		);
		vk.gamma_abc[51] = Pairing.G1Point(
			uint256(
				0x103884a414e5beb7b54ee6cad8029fb8145ee5fe9f553b683a98ae0a722b5e94
			),
			uint256(
				0x1eeae3bc72b4575c9c7d36c6bec49fffb5bd1112d634c36629c4735b81b709b0
			)
		);
		vk.gamma_abc[52] = Pairing.G1Point(
			uint256(
				0x16d3b67d4830fd39b4d060383b2cfde8d52c6ae8fbf11f7770a49a38c66585f8
			),
			uint256(
				0x1b20cdcbf3c230a380f11772e5c45f2ddf4d4e36c15c9aca0a7ae2ddd061ceaf
			)
		);
		vk.gamma_abc[53] = Pairing.G1Point(
			uint256(
				0x2b4597ba92a322af3a4f5dcf186fae2175c1d207cfeffcf93e4ec384fdd2cf47
			),
			uint256(
				0x212d89df7ae2ab93eb861218fd7d5983386ebdc1a9666abcf5dbbbdb778ae019
			)
		);
		vk.gamma_abc[54] = Pairing.G1Point(
			uint256(
				0x26eaaca700e60a18d57a34aa4fdb84925c88111df4833f11e07df9c71d0611a5
			),
			uint256(
				0x23b7c357d690d31209d9b6474a03d18ee3c6507b3406e61ae9906fc10fb0534b
			)
		);
		vk.gamma_abc[55] = Pairing.G1Point(
			uint256(
				0x19263f4cf541d434169a21281ffe43de65aa33c14dae07cc7b456f3de9ddf187
			),
			uint256(
				0x0a30e9a6cfe6785849257bec3266936b994d8c72d12e265af03c68e6c22c7f26
			)
		);
		vk.gamma_abc[56] = Pairing.G1Point(
			uint256(
				0x0a9f9ecf80160f711973c44e6f697e94d655182e6306f5368495aa1859c9cc1f
			),
			uint256(
				0x117f8d64e71502435ae9ae4b4d1d8d99f5365096cb4178d16e51c940afa591ac
			)
		);
		vk.gamma_abc[57] = Pairing.G1Point(
			uint256(
				0x1f08c8e267491b90999313ea485d8f3edcbf861633c63d0cd5a5c9c2c52d65a9
			),
			uint256(
				0x2af20551556836ef418b309c941e5a12f7e021ef7e67536b71feeff426139ce8
			)
		);
		vk.gamma_abc[58] = Pairing.G1Point(
			uint256(
				0x16e1b21f23393254b52707c9e97df9c098a85d8c773886369851fe6268e79eff
			),
			uint256(
				0x16c362b8d59221249643a718687886ccefcead9dc753dbc78d938ed5a6371f99
			)
		);
		vk.gamma_abc[59] = Pairing.G1Point(
			uint256(
				0x08d4f02961bf3a51cbbf628ca0e6a6576b18e2cfce465f0c9f708827c2510194
			),
			uint256(
				0x0cace61e237461d0cb8155b849218955101408191ad5d908c404403532051bdc
			)
		);
		vk.gamma_abc[60] = Pairing.G1Point(
			uint256(
				0x10bc2d1d5e34d0ea6feb208627985d073a9fc22867971ac95b53d416a8fc3077
			),
			uint256(
				0x11556e640d68a20bfcfd66ee151d23dd8b31dda3c43105b479afd1cbfda32611
			)
		);
		vk.gamma_abc[61] = Pairing.G1Point(
			uint256(
				0x1793385c47da4f5f47418b75c4eccc49f10850ac7f9c16ca2258fde1d2255e4d
			),
			uint256(
				0x1d022066320a525288324e64a16332d9984b50eba5fb34b3dacc1e64762d30e6
			)
		);
		vk.gamma_abc[62] = Pairing.G1Point(
			uint256(
				0x256bc9f54b8e55937fb64645e8e02acf6c8f824a46f1f75347988d90b99fa387
			),
			uint256(
				0x011a976528c7886389a811c3b96075d2073b7b40eac36b458162c5fcbd70ca64
			)
		);
		vk.gamma_abc[63] = Pairing.G1Point(
			uint256(
				0x09fd24635909f3be6a76f03b965bcaf728fab5232646105d1a2b7fa9e8646d5b
			),
			uint256(
				0x1ed1806423f3c2826ee139ba0d53112d80d52eeb9c75ddab24b3bb46e62dfeef
			)
		);
		vk.gamma_abc[64] = Pairing.G1Point(
			uint256(
				0x0cb1208ba5e9c7f3816790eb44a84fbe321cbb8b0a61ea9312edaa7bd9de5424
			),
			uint256(
				0x117979f1b7ad3aec34e37f4393df840fe223d5f258550377138844a4a3785c8a
			)
		);
		vk.gamma_abc[65] = Pairing.G1Point(
			uint256(
				0x2617ef08a6911b331101f53aac7f3992ffb0927b162d38d53199fab07fb7ee1a
			),
			uint256(
				0x289aabf1ac50694ce2f6ff4ca4f27c18803fef3fe29114f4e222973db5d090e0
			)
		);
		vk.gamma_abc[66] = Pairing.G1Point(
			uint256(
				0x2578d384a29655bcdfb4f548b65c529c9b74846bf99cb9397fe93e74140b83ac
			),
			uint256(
				0x059a3e5eb41b9df48281e17b27f030ba8d9295fd9182da8a152da2b5f9c272bf
			)
		);
		vk.gamma_abc[67] = Pairing.G1Point(
			uint256(
				0x2b8d131e20ffbc6abc5366763ee0c535b6e958c99d111430847604f395d3581c
			),
			uint256(
				0x2295f52070532cf705279fa3e1c46729e4d5ba404869c53b80c0bbbc37ec2a54
			)
		);
		vk.gamma_abc[68] = Pairing.G1Point(
			uint256(
				0x1ccb476dec67a226e1d840ebaf10762973c355e4a5f2e96cc3ec5bcbc0bff81d
			),
			uint256(
				0x0bc8207d4dfec3d601ea289b2337c8b3d2c9acfdd5370513c919a187f322dbbd
			)
		);
		vk.gamma_abc[69] = Pairing.G1Point(
			uint256(
				0x238889eaceda5deacde6909f53254325832859848533aa23c4244aa4280c4364
			),
			uint256(
				0x1e74f1a248f1d571b0cf8e06a14fcc1964db1bc64a4711e5b2bfb2e77cd66737
			)
		);
		vk.gamma_abc[70] = Pairing.G1Point(
			uint256(
				0x01789fc7027f6c4e6a47480272cb02096682cd529abeeff3f5d939a636057c6a
			),
			uint256(
				0x07bc070a53bfadfa232a84e3812b9b098ae6e0d217de89cb19d5bf89fd4b628e
			)
		);
		vk.gamma_abc[71] = Pairing.G1Point(
			uint256(
				0x1080507305f180d9a8bf67866f1723364678237c6a507fe7ba3259be5e81ad27
			),
			uint256(
				0x1282c26650fd2be966c6d61cb8ed6ae6ae1ec79de8e683a82776fb941043bc3f
			)
		);
		vk.gamma_abc[72] = Pairing.G1Point(
			uint256(
				0x161ac6a1cbf807ab1f98ba3b4fd640051de091644bf33a41171211d1a181304a
			),
			uint256(
				0x12f14d9058a41e5958a86b1a9762d926ed1d7ea3776fc02d704f489af68ac82e
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
		uint[72] memory input
	) public view returns (bool r) {
		uint[] memory inputValues = new uint[](72);

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
