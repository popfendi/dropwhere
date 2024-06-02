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
				0x17f064356a501e60756e86e2c47ef1c593b17284df50105165ea7c965c687783
			),
			uint256(
				0x2d142c9253fbb5a2dea8f4e8f79f9f4d5aa44647f977c305916e736ab5d067dd
			)
		);
		vk.beta = Pairing.G2Point(
			[
				uint256(
					0x15c7aa36415993e2dc18ab869f424a0530c78f6e2cb52a5ffb1db8efa4a80bc7
				),
				uint256(
					0x00d9a7801a3803919c0c06a7d505d76063560a09dca30a9a67acd80e05606fd8
				)
			],
			[
				uint256(
					0x1f725b5c15ca81303985ee7c136b70555bb7689b726a8544c3cd393a8d62a428
				),
				uint256(
					0x1abf6109de50a6c60c721a714aea1e10627256282b121eba8bc7507223c1c24b
				)
			]
		);
		vk.gamma = Pairing.G2Point(
			[
				uint256(
					0x1dbf91fa48ee106a669c0cfee5d824274e1c456e7620db0b1dcf24f2be8b71de
				),
				uint256(
					0x25eabaa142cb996167b11c35eb91004523d23803b78ed85411550149e552cb4a
				)
			],
			[
				uint256(
					0x20e2dd8c74afa2a460ccb5fcce9114729a23e9b998b8a7b91cef805a39caaa56
				),
				uint256(
					0x118cd3ddf390f26246b21ad6c5155024669e04b87e0ed82c4458231d760abc31
				)
			]
		);
		vk.delta = Pairing.G2Point(
			[
				uint256(
					0x16b6f68d28569928df4e8900a951f38a2f3f69242b03744a0285af95d422ab30
				),
				uint256(
					0x1c8559d2fd89a3dcbcb61461946546f919600a103a5d517fff4ba112e21fedc2
				)
			],
			[
				uint256(
					0x23bb273ba9122b14979046ffbfc74e25f7dc5dafccc98f89b25a87c99eba3c0a
				),
				uint256(
					0x2870007c2edebc7e9da50f6779b44f15427130be58144f2db62545782bb8c5dc
				)
			]
		);
		vk.gamma_abc = new Pairing.G1Point[](105);
		vk.gamma_abc[0] = Pairing.G1Point(
			uint256(
				0x165057040bcd226ca5d5b9eb562df980e9f3b8af6805ea7fff38e9b7c870a831
			),
			uint256(
				0x27cf67ff085260f533e7c5ef8eaf7c03e50950e335fbe30b78cd2ded8105d688
			)
		);
		vk.gamma_abc[1] = Pairing.G1Point(
			uint256(
				0x2994afdee524e96df2e4576e5ab62c5a54e5e87dcb665f46691ed1b0f81544da
			),
			uint256(
				0x0c064bcac55d6538b12568f9e8302efe54a35e2f93f07c3cb50f2a9b4ac7697f
			)
		);
		vk.gamma_abc[2] = Pairing.G1Point(
			uint256(
				0x0ae6feeb478720a1f5dc5e6e4ea5e99ea8141eb99b1686c257fdfb88cefdd483
			),
			uint256(
				0x03f2d19f3124738fa571125b52a1cfd15b6fc22674ed9611c8fd4fd806cd52be
			)
		);
		vk.gamma_abc[3] = Pairing.G1Point(
			uint256(
				0x108f572f3bf88de652d9850b979e3b9b885b6ed9857ecee1dff6669a4d4a0607
			),
			uint256(
				0x251f3edc7bcee75b1ecbca74dc1014962a41cd2f92fd55b60ef6a0f48b953fb7
			)
		);
		vk.gamma_abc[4] = Pairing.G1Point(
			uint256(
				0x01a527750bc9f7caa619ba68a4066ce039946e13fdd764f787a1eab96a2d1391
			),
			uint256(
				0x01bcfca25fb3af78735b3e85bbb1d7cd2482a7ef857567fd3e1d46fa683c86a2
			)
		);
		vk.gamma_abc[5] = Pairing.G1Point(
			uint256(
				0x198ee61640911035f8558ef9c0537d1aa66a7c85ec39368de4957ef8bda71fe8
			),
			uint256(
				0x16fb67157a882612dada66249ebe629b1e3ea23a7e9fdc6e579294ca891a3c73
			)
		);
		vk.gamma_abc[6] = Pairing.G1Point(
			uint256(
				0x0ead4c9b57331dad928b1f58162218b137d1e56e1f657d48f060a128fcc92c1e
			),
			uint256(
				0x0a12433c8b8126594d989b6cef26db90a9bb50c3a7d29a9573781f05f5078fc6
			)
		);
		vk.gamma_abc[7] = Pairing.G1Point(
			uint256(
				0x25fb4042e9cdfac3df0b73083e07045f0d4167e26b3466a1c6d78ede6f9cb1df
			),
			uint256(
				0x09662959cd155c01edc24347d6708f4af8f8ebec3d94276996e3e9825abd0934
			)
		);
		vk.gamma_abc[8] = Pairing.G1Point(
			uint256(
				0x1476a3f60113e0dc9f1a40c0934ae63f5942c0651485d700411d52e810d68b08
			),
			uint256(
				0x1bdee0fbddca7536113ef2171be442e4431cc6700c342e327bd9ab8665f8d579
			)
		);
		vk.gamma_abc[9] = Pairing.G1Point(
			uint256(
				0x1a902ddfa4dcb6b9e2d16b0119997af65db3733a59ce3dfb723079021ff37808
			),
			uint256(
				0x2a7b86842bf114b585270224769a8c766297ec87746e66223a141cc5b36f30b4
			)
		);
		vk.gamma_abc[10] = Pairing.G1Point(
			uint256(
				0x135236e089d87cb94383eb8159d330003647c500cc3dd4d05383771de169b9ee
			),
			uint256(
				0x24925edaca06e2589005d193cd1ad0e034a7a596cb2776a8fa9a7dc50f28bc33
			)
		);
		vk.gamma_abc[11] = Pairing.G1Point(
			uint256(
				0x17d0698152bf6bc4ce31d26aeb4184325a98f55b353009db1aef3f8d85054464
			),
			uint256(
				0x10720627afff1ced7b0d2940bc467558eefb5887bc3b23967927e714457be918
			)
		);
		vk.gamma_abc[12] = Pairing.G1Point(
			uint256(
				0x2aeaf0daf5b49f9e39cc43a4796130f425ac529bd8ce7f946e592d66d8844555
			),
			uint256(
				0x2708fff06275c5e53caa4529c9704e39bc73198c278bdf4099d01c025eb49fbc
			)
		);
		vk.gamma_abc[13] = Pairing.G1Point(
			uint256(
				0x2d5dcc4e997b963ee4c4d3f2b8ab8374ebdad684c67e1942727820d6547b3009
			),
			uint256(
				0x18b4567b8d4fc312099cd9ab26b5e8c2eccab591e9fde21172929876ec58a6f8
			)
		);
		vk.gamma_abc[14] = Pairing.G1Point(
			uint256(
				0x0daa476cf27ecad62abf53f28c46eb78d0ebd610dd662f7236e7e6cad16bc084
			),
			uint256(
				0x05000f749fe510753191ad3b8d49b2ba8e11feebafb63ecd38e63ee4e5b66a54
			)
		);
		vk.gamma_abc[15] = Pairing.G1Point(
			uint256(
				0x1fbb03657abac0d52295795dfd12736f1d12883e1521cdf934d0bcb351fd62fd
			),
			uint256(
				0x165b7a70850a117a22041e56be22d34dd641b3e8ee9e12a826889d74cb59f9ec
			)
		);
		vk.gamma_abc[16] = Pairing.G1Point(
			uint256(
				0x0f87e242c9631070e6bde7fb26c52d5c4255fb65a17a4ae8b97eadde57936dd4
			),
			uint256(
				0x2f5cdd28f2347803df0497c1f252bf4a92e38e9d2956c979e0d7cef081bd1a02
			)
		);
		vk.gamma_abc[17] = Pairing.G1Point(
			uint256(
				0x2ece5843c0c3866d163229fd18eb7c1f260d05343a9c7daf97154dd0a983268b
			),
			uint256(
				0x1b5097ffae9ef7f94550734d47f1237855b37f66fdfc63929400ccbb274df758
			)
		);
		vk.gamma_abc[18] = Pairing.G1Point(
			uint256(
				0x1e83ccac3230e0d2c7b44d23fb6f54ff19358dc74370830d392af659f4cf2502
			),
			uint256(
				0x17ed077a60bf1cef3fa44ddc606262be0ed82f7f0629fe9c5bde5f9dce7731b5
			)
		);
		vk.gamma_abc[19] = Pairing.G1Point(
			uint256(
				0x163a5c953a027625c96bc66774f09efe6d3fa9cb55f5ae9830414a1f76dab5f2
			),
			uint256(
				0x27beec61cf4cc910e5adf2818eb897e7bd1055fa280d133446b0967183833586
			)
		);
		vk.gamma_abc[20] = Pairing.G1Point(
			uint256(
				0x04c221799a9192014b9d36c424398a3045ccfe952639bf4ad985a9b77fdd37a7
			),
			uint256(
				0x18491b691ffab5faf69547fd3c411c0978ad92323a499f8b7eaa4ea763980629
			)
		);
		vk.gamma_abc[21] = Pairing.G1Point(
			uint256(
				0x00aac33ebca792518a4394b4df1b06219f1c143cef1359d459e3742b7f72a8aa
			),
			uint256(
				0x144b720e0b0cf924fa18bf173a3d9f9684b029570c7acf2a02feb47c630dd511
			)
		);
		vk.gamma_abc[22] = Pairing.G1Point(
			uint256(
				0x10d75534600cd181f4fe02e4486bc319fc813e135115b75c9f8a65db4348e6da
			),
			uint256(
				0x08cc278517be01341beedbfec634e39523319ba12e3fd7940ef1d070e78c737a
			)
		);
		vk.gamma_abc[23] = Pairing.G1Point(
			uint256(
				0x0eb7532552fa7be27da684a15419bad615436062b848e6a58b7004f2c7c88f69
			),
			uint256(
				0x23243c10f537da22e0a1963976ae7ebadb74417e1704bec4bb2201466c912b43
			)
		);
		vk.gamma_abc[24] = Pairing.G1Point(
			uint256(
				0x0852003ac577df1b09ee1a25f25c1dbae775916442727aae8b90dff07ab8bba4
			),
			uint256(
				0x2feb3da1d1781c13cdf49d3b929e03da79770ea974fb68010f383171104e9274
			)
		);
		vk.gamma_abc[25] = Pairing.G1Point(
			uint256(
				0x2c76b67c62305e881ed5df09eeb7cb666be50e8f7fc8a318f41d77279c8ec780
			),
			uint256(
				0x2462ee65e25270db2de26667d3600c9d524d0e542fdbfdd01e6a99b02f4d7cdd
			)
		);
		vk.gamma_abc[26] = Pairing.G1Point(
			uint256(
				0x08571de05f056f96cf13cde78af24ca45dbdfa38de35ae01426a57fdd4161891
			),
			uint256(
				0x19948834d7b98b9bcbb5a2fb7cc3e8c1ae50d5606874ef5706960785294636f4
			)
		);
		vk.gamma_abc[27] = Pairing.G1Point(
			uint256(
				0x2b614a611442e5f70d56847c3004e5bd8c4264c2eeaacaacf196f53934ad1e3f
			),
			uint256(
				0x1efabb49fc67cf4cd7569d0dcd76b4d3e5863e20c97abf7283455a835fbcf767
			)
		);
		vk.gamma_abc[28] = Pairing.G1Point(
			uint256(
				0x06701495cc029794e97d4fad59e81b4fb5f731c746e5c2f0ca041b56c75752ff
			),
			uint256(
				0x2ac727bc40443dbb5f60140007e63ca24b622d6c23780eca124de36a16c122c9
			)
		);
		vk.gamma_abc[29] = Pairing.G1Point(
			uint256(
				0x197f55c7e0e65359768cfa134b2b9faa4267636192a69c201046cde35249d339
			),
			uint256(
				0x2e50e8ff587185b7fd65a31084f0166241928f10ed1ccb8c2cd54e1201ddf6c0
			)
		);
		vk.gamma_abc[30] = Pairing.G1Point(
			uint256(
				0x032fcde0336826c249f2fa0b780c2a99be1d08739294b971fdfabbe65a9be103
			),
			uint256(
				0x21c132dfd818c78fbe0c93a4c88fae7d034de0a3a29d5bead8ba61ab1c9ff225
			)
		);
		vk.gamma_abc[31] = Pairing.G1Point(
			uint256(
				0x26dd178d09be84acbf7f367255acc563fb184a5594496eb9341fa742ef365c6f
			),
			uint256(
				0x11d92f7ba5163aefd7e765544f1a572cfbde50c1252d4219f440319a729c5c00
			)
		);
		vk.gamma_abc[32] = Pairing.G1Point(
			uint256(
				0x02e5c89e2fa9f3be33f38a60d6ede0582c651376ad7f9ede8e8e442b2c8441a8
			),
			uint256(
				0x043b65e11fd833567f16f4f8d12b0b513e19957ec1d5ed5934902ed57a9757c9
			)
		);
		vk.gamma_abc[33] = Pairing.G1Point(
			uint256(
				0x1f079c6f3c3b9f30cca9f7ce5cd0f2ae38824d9cfdc87fac02d82d2f03120094
			),
			uint256(
				0x0a1b4b3c18c2581f1e1e36e4c374b59519581f1c9a2ed90a185d3501ee158402
			)
		);
		vk.gamma_abc[34] = Pairing.G1Point(
			uint256(
				0x2eff2fdc11225c459ada696d2523f2f944b1e75ad45632f6ff92cdf077e3aecd
			),
			uint256(
				0x1197b667d1043b34d2ceb2a56cd132242ff7242d3e8709215d4bac1b88f3b605
			)
		);
		vk.gamma_abc[35] = Pairing.G1Point(
			uint256(
				0x05881974652f0e0cf865957d967325ca1008fbad69a0d4b5696aff75016758e9
			),
			uint256(
				0x17459f3627201110a12bf0a460e86388c566e2b3c58136e488aff9117772b7a7
			)
		);
		vk.gamma_abc[36] = Pairing.G1Point(
			uint256(
				0x146dcd6cdeb1246246008aac45b8bd3a14e608fca523fc0a6eaa89f4afdc7b7f
			),
			uint256(
				0x1f8988f237ca463259f3137973a62e3df96b1bf75b1065703296bdaa15945524
			)
		);
		vk.gamma_abc[37] = Pairing.G1Point(
			uint256(
				0x11277e667f67f45cf68a7174a6c4dafce1141e4eacf720c34b2b48ad0f645177
			),
			uint256(
				0x0dd65939e568ee03485c491c7a187488cbdcddc5fb0d8237458f32b9bdb4e6cd
			)
		);
		vk.gamma_abc[38] = Pairing.G1Point(
			uint256(
				0x07152caa0d14c7829717a03f2f06cf59301ac55617266d5ed38604c3966f2f1a
			),
			uint256(
				0x1ac5cc05404657f26904d375d0d2595e39eba7c96cc1125e5614e265b059b834
			)
		);
		vk.gamma_abc[39] = Pairing.G1Point(
			uint256(
				0x2dbbcb01e20f90548600ecaf4ad8b05c3798e4435b44d6505a1b29c9893476d1
			),
			uint256(
				0x1edf957cb0ad0a1b8f64b3b8fed4adbbdf3900b1e6a82505c24983f352091bca
			)
		);
		vk.gamma_abc[40] = Pairing.G1Point(
			uint256(
				0x08949181d2b424027baee843cbe0770f0caa1777a9f6ad59f05e057f1316e2e5
			),
			uint256(
				0x096077e35a70328da69d3d0e35a03c18df8723cca11cbc93aa76027fe7f77d54
			)
		);
		vk.gamma_abc[41] = Pairing.G1Point(
			uint256(
				0x28e9a4933dec7c5eff185c22a78ed23ca7b2cf21b976c4987b272c23a7086bb1
			),
			uint256(
				0x0838eb69c39c421f862355c1b1285320af436e6f33fdd77eb724c5e7c19519d9
			)
		);
		vk.gamma_abc[42] = Pairing.G1Point(
			uint256(
				0x16327c958d2bedc9c7b24d4f58d7ab5dd073ca800bd44c99170cc15b863b4001
			),
			uint256(
				0x1523b348937c6e04ca3c22c3802ad5cb6bce0ee8f289098f54755f5abb6ca64f
			)
		);
		vk.gamma_abc[43] = Pairing.G1Point(
			uint256(
				0x01aa59f599e76cd113bf529251c1b79738b24c71fdd2309dbafedf27aa454afd
			),
			uint256(
				0x1d0a1214942931ee54ab26da07e6b036df4a93ca5cea72777c88caac0c5390fd
			)
		);
		vk.gamma_abc[44] = Pairing.G1Point(
			uint256(
				0x0399300a517815f1fa14bf366965659920e373b7b56c589738eb3d06c9bdf220
			),
			uint256(
				0x13abcd2a3ffe4ba0b98ed8758606b201614de16da64ba1cc2140148102a9ae11
			)
		);
		vk.gamma_abc[45] = Pairing.G1Point(
			uint256(
				0x2925e6968140126b4439be612a37873f5e4403185ab45c99d0b7fae3d312178b
			),
			uint256(
				0x233486bbe1aae1229c9fa1bbc3ee8dc56698640ae1a3dfe92c142f5729d170d9
			)
		);
		vk.gamma_abc[46] = Pairing.G1Point(
			uint256(
				0x2666dc167d1d5a5e1d016f9593005a1ac099ac971b91019d759916f6519dae5e
			),
			uint256(
				0x22b7f40057db31b06152fde42a517f08ad6c27d9014af1fc4b299d62d4835367
			)
		);
		vk.gamma_abc[47] = Pairing.G1Point(
			uint256(
				0x080d26eb177bff422b3ad823119f5b7d62e579da3a56825b9ea8306be67a0037
			),
			uint256(
				0x290eda1afa5b4c8b59512a431826f5127bb482112084dccc166845400199c3e7
			)
		);
		vk.gamma_abc[48] = Pairing.G1Point(
			uint256(
				0x24f9d76a669f5178ec9c05de8c495a276aacb7858219af9e4affddf2ba7fb4e9
			),
			uint256(
				0x0f2a8a1c97b2ef0bda2122dfe9a1897904ff7fe891f77408c19ade8abb94234d
			)
		);
		vk.gamma_abc[49] = Pairing.G1Point(
			uint256(
				0x0d8b7d5d970e3c244a3e63b4d172f831b57e4892d6454507af7de5b1f2fcbc0b
			),
			uint256(
				0x06e9f3f761453ca4befd08a242fe29dc4ddb0934e3b024cf061bc94b32993fbf
			)
		);
		vk.gamma_abc[50] = Pairing.G1Point(
			uint256(
				0x1a8b34b710e05954c54ca42d6eb420af95e33f73acc62731dc6b1a0c9aae0977
			),
			uint256(
				0x0c04ff25670818b1cf6344db9fb145f26189c167d18de941b0fbb627e0f3d185
			)
		);
		vk.gamma_abc[51] = Pairing.G1Point(
			uint256(
				0x1517a3e3736fa30ebb66cfe7e06934d6777c948421d8c8f148c1ed5130d4d3d1
			),
			uint256(
				0x0f3e1c23ce3bf49461a487b13fe261680a5aa5daaa63d4d6584545a9185ac9ae
			)
		);
		vk.gamma_abc[52] = Pairing.G1Point(
			uint256(
				0x0024515ea2bb36b2c113b83cc3f5aeac3b3802ee95a492c7f3cda8ad543b0dee
			),
			uint256(
				0x2dc3991fd9af77db8a155ae60673f8f011b6b864a58ba8f61cca10293ab96f37
			)
		);
		vk.gamma_abc[53] = Pairing.G1Point(
			uint256(
				0x1f6019b97e817ae6cde1a85645e4b811ba0aa03a9aa8c8849516bbc884710a82
			),
			uint256(
				0x0d75629f5d59018960ac08b3de490ad3bfedc0f7f227fbc53bd1ccddd8005a1e
			)
		);
		vk.gamma_abc[54] = Pairing.G1Point(
			uint256(
				0x0bd208cbc9cbc9ff5656df80028cfcfe2fc52a1ef010cf6280f8255b9d2bc604
			),
			uint256(
				0x1c47b5b74b7a530dbaf4b39994300decb1936a877b8e425ef743560dcf701f20
			)
		);
		vk.gamma_abc[55] = Pairing.G1Point(
			uint256(
				0x2be940ff93b08baa869e51547127bd020d41785ad1e53769f27a7a937840300c
			),
			uint256(
				0x29309bb73a4b5cdbffb0020ce6278af19bc304d1ff4e9162ef21718957532240
			)
		);
		vk.gamma_abc[56] = Pairing.G1Point(
			uint256(
				0x137f859a18d9388f3886d8b32699c2e137c67d3bfb077647b9e74c2f1f69103c
			),
			uint256(
				0x0b38e3c67ab4be536d52545641cfc60594aaae608fb4735c0eee5b698d410e0a
			)
		);
		vk.gamma_abc[57] = Pairing.G1Point(
			uint256(
				0x0ed75db1d10ea84f06c3fb1cf2e13f75d1d2d8aa3d69dd543a0e539641741979
			),
			uint256(
				0x21390425e9fb94ab7da096206596544f00bf10e5ad905fc5d5cac6d4585f8040
			)
		);
		vk.gamma_abc[58] = Pairing.G1Point(
			uint256(
				0x166248a08a768cbc928a47b5d861697c97e08ec8ef9c2e5167607498605270e6
			),
			uint256(
				0x2c7ed260c51745fb96311d28c5d3791b2c9f3b49a4f3071edcbbb2184ed3b3a9
			)
		);
		vk.gamma_abc[59] = Pairing.G1Point(
			uint256(
				0x1ced791823e491316478b3ec762bd8515e9d560cd93e7e95396e07421b1236b7
			),
			uint256(
				0x0e9cd97c8aa6a304e270e310ca2c6ca7c26acd95bab20ea6e3cc9876a5d70c27
			)
		);
		vk.gamma_abc[60] = Pairing.G1Point(
			uint256(
				0x072057e48c7511e0e1f0740a7e6358d652f7285509c42324406356f08fe6bc51
			),
			uint256(
				0x1f58a498f68ad46c02c56fc2a75dcd36096bdcc53e35152d8e7eb87fbbe66e12
			)
		);
		vk.gamma_abc[61] = Pairing.G1Point(
			uint256(
				0x09382e86bac4f267276636cd8a134b08e992f2506d9f55c33978b40bfd036c0d
			),
			uint256(
				0x00cfaf9c50e0e160d89e068e28869f09ab7c1c6b2112261d15b44bb992abe2da
			)
		);
		vk.gamma_abc[62] = Pairing.G1Point(
			uint256(
				0x05a0b83410aeec7ecf9ba1aa01a1bf7a26611a023681f318fd6a21055fb76aa3
			),
			uint256(
				0x210aa149a47751ebb87dc9087b6d1fbe5fe5d8ad0bb499a59925930cf496a6a8
			)
		);
		vk.gamma_abc[63] = Pairing.G1Point(
			uint256(
				0x140d9f6d731a24b428d5684fa64c4bf15eb801c43931d480575b0292294fd656
			),
			uint256(
				0x212b29482bf655ddb79952e6236e844bbd2e7c08ddf2bc0c1b5b8723b56be23e
			)
		);
		vk.gamma_abc[64] = Pairing.G1Point(
			uint256(
				0x0a959c8f12788a8b88ff4e95e111b2d7432949c24be1d7d419ca3fcaaabe01b1
			),
			uint256(
				0x2f02b607e70d81416075693d89dd51e6c5ec6d766a19d3ef5e64a78f4f79395a
			)
		);
		vk.gamma_abc[65] = Pairing.G1Point(
			uint256(
				0x1cb30408ad20617321512be0ed0b184c0ff0e10b0f64ac352d356f543ec2f953
			),
			uint256(
				0x25bdd96400481b55ad8d67c62d0072db495d2c3670b2d1a0d4b8390db303083b
			)
		);
		vk.gamma_abc[66] = Pairing.G1Point(
			uint256(
				0x2421e54032056d44704274f1d9e4693a67040812d30daf303c407e4967e1edf4
			),
			uint256(
				0x0c32e961e7dac750b3d33ef82ab146a2b194d3e90cee5d1d8a3385873b59e120
			)
		);
		vk.gamma_abc[67] = Pairing.G1Point(
			uint256(
				0x1830e8741113c8ff7e6f924d92bb36df360eed7b623c1c813a25275fee2a07fa
			),
			uint256(
				0x0d203941b84551a2dacbd1bccf2d06ba74fd5a69f63a5adb35ff038ca273961d
			)
		);
		vk.gamma_abc[68] = Pairing.G1Point(
			uint256(
				0x2a4baee291776f691e754659a162c0e8d9fbb61a90ed4f01184f22ff301e6413
			),
			uint256(
				0x1df402dc6d0bad7ab1d3a14ddb1c5b7570d28e23cd8593161205ca64a7b0ceab
			)
		);
		vk.gamma_abc[69] = Pairing.G1Point(
			uint256(
				0x12fd490490bfaeedab82f314c4dabdb14588e20defa6e8a9d6600f5a7403f408
			),
			uint256(
				0x11e255f90ae5777029e41e42e5042ea7a5ccb5ca9d4fbeebbf0b0a4991b3b84b
			)
		);
		vk.gamma_abc[70] = Pairing.G1Point(
			uint256(
				0x08a2614d16c331fe51816c39392b0ed232985c006122a974376ce001fb4ffb47
			),
			uint256(
				0x258dac478bf1924bad96970f6add93f324cca4b95eb28b1d244f4a35f3727284
			)
		);
		vk.gamma_abc[71] = Pairing.G1Point(
			uint256(
				0x2ddccd6287cc03389f0040ea1ce55b0826ac00a0b63094a8ca08bad5a5d12637
			),
			uint256(
				0x107a0f4448008cdbfadfbe8a2beed574446c124cbdd22a0d50b67fca5d4566da
			)
		);
		vk.gamma_abc[72] = Pairing.G1Point(
			uint256(
				0x17ca6fee1a35cc2598337dd8becb5f5be724598633c5137e839b74ccf38979eb
			),
			uint256(
				0x281cdf7084d4798b7d4c1e452f17d34222b0395eb8b381e5f3e329d2b5b1e3ea
			)
		);
		vk.gamma_abc[73] = Pairing.G1Point(
			uint256(
				0x2c7b97accb02b148f1943afa732c21f964cc8ab4ed263f058ba86f29bb05ccc2
			),
			uint256(
				0x28ffe96a8e73c828493276377258140430101f1e3f0e2b6810a7fc9d9c63a059
			)
		);
		vk.gamma_abc[74] = Pairing.G1Point(
			uint256(
				0x00692111fbf104eebd4cfd278fb034cb7b47f291f6b402763da07fcee78c2486
			),
			uint256(
				0x121cb5038009c605368a3fd755ec4fccd8d85db3142bb1d06a45d4e707f5976f
			)
		);
		vk.gamma_abc[75] = Pairing.G1Point(
			uint256(
				0x2f006c987877389117eb060123730be2a037eaed95465a70cde38af4f705524b
			),
			uint256(
				0x160cd52e7272d1d7ba7bbbfd9e7bef03194265a12bc2e379a56d95260b4e08b1
			)
		);
		vk.gamma_abc[76] = Pairing.G1Point(
			uint256(
				0x164da54224ae4da6127ca82571b43ed74cae01d615f30acf04b81d025b317d5b
			),
			uint256(
				0x2ccce21977185ed1a4cb5bb877f93efddbf5722604553841009dddc000baf777
			)
		);
		vk.gamma_abc[77] = Pairing.G1Point(
			uint256(
				0x27237fc718e2306c2b984805fbc77b34648d849511e19e163912d89b483afb89
			),
			uint256(
				0x18663ed40b00e061965c2232744af665036b509826f4c6ecf3ed043c55e066bf
			)
		);
		vk.gamma_abc[78] = Pairing.G1Point(
			uint256(
				0x1aebbd348bbc80cbaa5cd80b8e977d20de47a6bdf2db411a33b12579c0e39b55
			),
			uint256(
				0x012f7112de133f74a899ef6c59a9cba3a22375a72f950f7df2479a08381da172
			)
		);
		vk.gamma_abc[79] = Pairing.G1Point(
			uint256(
				0x1fbda8448a8fc8910cbe50ff7252b8b5084c02854cb5499e23632563ffd7bffe
			),
			uint256(
				0x258b5daa915699a0fc944d2b1d415eb75ace643c07224cc36d4e6952a4611cd7
			)
		);
		vk.gamma_abc[80] = Pairing.G1Point(
			uint256(
				0x00748c486082c06bb9cd0c90b4930e326b1d67b9f0a00b8adadc4cbe583a5951
			),
			uint256(
				0x11af660d0569967451da4d43723886f94d09bb7fbf21b1ef510d2c26948e0028
			)
		);
		vk.gamma_abc[81] = Pairing.G1Point(
			uint256(
				0x26eced7498e499910e4e1238126797ea31e039f28e0c198ea488613822a11f4a
			),
			uint256(
				0x2745cdb1136d2b97bdf6f1de310ef027bf1f38221b3b250ec1e1f4c466b88388
			)
		);
		vk.gamma_abc[82] = Pairing.G1Point(
			uint256(
				0x181952a1dc7878a57bd23bd12a1eb24300e4a7b0398e0d2c5234836f83f2d5d5
			),
			uint256(
				0x0dcab42a365fb2320a0de0bf421a0d5e32ccebc7906042faaa1acd303ab2bfad
			)
		);
		vk.gamma_abc[83] = Pairing.G1Point(
			uint256(
				0x1789ae22aa860a5be0a5dce021ea0a1aeae140e74d3a20d57669424004e2931f
			),
			uint256(
				0x281bc66e1af8e160746e763ca1e3744b524b91259729d7338fdec0c8dacd09ff
			)
		);
		vk.gamma_abc[84] = Pairing.G1Point(
			uint256(
				0x1e224a2a3e8a7b5efece4f06fdfc84add13fe6ddbbb6de83c998b019f7521971
			),
			uint256(
				0x08f3b889a7139fa6849531c2e87545aa8952ce00c5be0f6a2a0a7549fcd69972
			)
		);
		vk.gamma_abc[85] = Pairing.G1Point(
			uint256(
				0x13fced5ff3503b2e1abb0350fa23ad06b9207135d100112c3366566d0ecba447
			),
			uint256(
				0x072ad38fb7857d98b38d352d782d233ade4ab86b4abf9d48f78b56e3e83dfd54
			)
		);
		vk.gamma_abc[86] = Pairing.G1Point(
			uint256(
				0x0b62107f1ad98596709786ca1fad3618fb34b26d6e147810214e21a41edc8f89
			),
			uint256(
				0x1b93fcf8e7f643b558be22e3ed03000b84e4625a01df22a08ac48f94d11a0170
			)
		);
		vk.gamma_abc[87] = Pairing.G1Point(
			uint256(
				0x2790495a39ab4f655fdc46aa014050754762eeacbbe32755e84ac1990a577416
			),
			uint256(
				0x0065659a5edb3e80425e2f801f843dca1cc2395e623e52d482faf541cbc3ad77
			)
		);
		vk.gamma_abc[88] = Pairing.G1Point(
			uint256(
				0x030d80960927654044193e7d3f941e3114dc3cdcea37dd9e897016c1442c6615
			),
			uint256(
				0x02a51c1cf1da533dad4854aa07a0754db44543122d31d57590eb9be4cfff9c13
			)
		);
		vk.gamma_abc[89] = Pairing.G1Point(
			uint256(
				0x2646a5b59e637fcbf588c7336fd711cc9b6750148b7e4aecf9e673a25f26afb9
			),
			uint256(
				0x03f749eebf9d146006ed791ec5edea9dfdcd9f7996424e6632e7204d2a9c2368
			)
		);
		vk.gamma_abc[90] = Pairing.G1Point(
			uint256(
				0x234449323baaf662b5ac6be9531435eb0d4970e5bd14cad155d4395e5d33b240
			),
			uint256(
				0x1fa6d205b7e1de3814effcb02f025cc89b83b79e00075b43cb079dcc150309aa
			)
		);
		vk.gamma_abc[91] = Pairing.G1Point(
			uint256(
				0x1ded97940a7d3941da071f78169fd90dbcccf33ac248493a69e6ebb4bd40c439
			),
			uint256(
				0x228e212d4784f043ec92125d99cac52406e611c60a4b160d47af229c8444dc21
			)
		);
		vk.gamma_abc[92] = Pairing.G1Point(
			uint256(
				0x171397ae442eb2a922ff45a75f7d898971c2f12352a6b880627e500e4dc8e833
			),
			uint256(
				0x2b9d1f782fef757bac3ad123e718074bd843f5d0e373cbd53b6f652fd192b050
			)
		);
		vk.gamma_abc[93] = Pairing.G1Point(
			uint256(
				0x29cb4f4c59d4c1e120dd3e65acf0e1ab2320a440c750ab9c71a8a540eb5ef0e2
			),
			uint256(
				0x222e613d34af9b81a2862f0483bd7051d9c28aa958d9e75ada4d08c533ee7333
			)
		);
		vk.gamma_abc[94] = Pairing.G1Point(
			uint256(
				0x207b9531a4ca196cce0f98b5623770a0c9a50df315d4fd99b2b7ccba13d2f029
			),
			uint256(
				0x1768c972289278394411382b0efee464435e3e2e631e92f0b7e54caad462c900
			)
		);
		vk.gamma_abc[95] = Pairing.G1Point(
			uint256(
				0x0b8b1e281e4193975b9b19362493b82f64e5f31bde6478dc895c44493697d70d
			),
			uint256(
				0x16e23ea141ca48ca8df52aee0bfd8be1de6a7605660ab106c09ec41324265dc7
			)
		);
		vk.gamma_abc[96] = Pairing.G1Point(
			uint256(
				0x2d398713c8275cafa4007ad4af1c76de671b9b42cd2fb1096c6d9e700c23f2aa
			),
			uint256(
				0x2902c3077a93a7f828b4b98b54cd8823cdf8c2955c6423eb0e073c11bdcc3d1e
			)
		);
		vk.gamma_abc[97] = Pairing.G1Point(
			uint256(
				0x10bfcdfe6b8526db1ac09732694f4c8318f31c898a31d0f6d733741911176b15
			),
			uint256(
				0x0d5dc6ac353c05c3d32c4fdcd57a5d500208262328a2788bbab771abb4937fe1
			)
		);
		vk.gamma_abc[98] = Pairing.G1Point(
			uint256(
				0x028c3f861c24f96d58704df44e55f4b3c460d08bc8bc11bc48d6221fd3315a11
			),
			uint256(
				0x23f0a9ad778da18e39767bff973fa1735cb09b530c47ac419e05f95efb39c2a3
			)
		);
		vk.gamma_abc[99] = Pairing.G1Point(
			uint256(
				0x26c997ddc0c1c1f113f5a8bb3705bbdbd4164da00095e3aef3986b909170d128
			),
			uint256(
				0x07f1c610b2ef3913e3942f5f7056f42a2e84d1ef4cbaa5749e19094034532bd2
			)
		);
		vk.gamma_abc[100] = Pairing.G1Point(
			uint256(
				0x0072477534beb69b11e64526a7e923b75730cb616786be9d9d9fed9cf803a18f
			),
			uint256(
				0x2fb3133d87709176f1797b5adee6c81faa9456455a2de4ea3badc3757d9d90cc
			)
		);
		vk.gamma_abc[101] = Pairing.G1Point(
			uint256(
				0x1039340407ba910e5cd59eafebf4a93d9800170eeb3a7e6064e4891004406992
			),
			uint256(
				0x2e07fc0d76206683b80ffc36e9a5bc340e7ea5d4612c0e32d1b82e8ccfe5b6e0
			)
		);
		vk.gamma_abc[102] = Pairing.G1Point(
			uint256(
				0x05340d44b594c1fd26c5011f1da4f6dffdb2c6f9df66789ce774f1bc9e32a474
			),
			uint256(
				0x1ad7cdee03754880c8fbdbaa210175dac2e9c368cdfb7a0d5c802c15b1bee897
			)
		);
		vk.gamma_abc[103] = Pairing.G1Point(
			uint256(
				0x079ac210ca46d4d2e2a6428711d6814473ef134e4da6cae5defa0fdca5f0cfa5
			),
			uint256(
				0x2e7d24edfd7f2242d77fe33b64fadd36ea5cec49461307b404f926bc7620c1e8
			)
		);
		vk.gamma_abc[104] = Pairing.G1Point(
			uint256(
				0x112b16283efdc933477319ee0f3e96fa19ccac03a202e851423459ea3366de5c
			),
			uint256(
				0x2955e03517c37f345f4e5410caba73df6dafb546a2776d9e3091f8304eb520af
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
		uint[104] memory input
	) public view returns (bool r) {
		uint[] memory inputValues = new uint[](104);

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
