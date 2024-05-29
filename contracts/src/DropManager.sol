// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import "forge-std/console.sol"; //REMOVE AFTER TESTING

contract DropManager {
	struct Drop {
		address sender;
		string message;
		uint256 timestamp;
		uint256 expiration;
		int256 lat;
		int256 lon;
	}

	struct Message {
		address sender;
		uint16[] content;
		uint256 timestamp;
		uint256 expiration;
		int256 lat;
		int256 lon;
	}

	/*NOTE do we want to have 1 struct for both message & drop to ensure only one can exist at a co-ordinate???
    these structs are temporary and need to change just to get the outlne done.
    */

	mapping(bytes32 => mapping(bytes32 => Drop)) public drops; // maps tileKey => uniqueDropKey => Drop
	mapping(bytes32 => bytes32[]) public dropKeys; //store active keys

	mapping(bytes32 => mapping(bytes32 => Message)) public messages; // maps tileKey => uniqueMessageKey => Message
	mapping(bytes32 => bytes32[]) public messageKeys; // same as above

	event DropAdded(
		bytes32 indexed tileKey,
		address indexed sender,
		string message,
		uint256 timestamp,
		uint256 expiration,
		int256 lat,
		int256 lon
	);
	event MessageAdded(
		bytes32 indexed tileKey,
		address indexed sender,
		uint16[] content,
		uint256 timestamp,
		uint256 expiration,
		int256 lat,
		int256 lon
	);

	constructor() {}

	function getUniqueKey(
		int256 lat,
		int256 lon
	) internal pure returns (bytes32) {
		return keccak256(abi.encodePacked(lat, lon));
	}

	function getTileKey(int256 lat, int256 lon) public pure returns (bytes32) {
		// 1 degree latitude ≈ 111 km, so 1 tile = ~11km sq area
		int256 tileLat = lat / 100000;
		int256 tileLon = lon / 100000;

		// negtative, non whole numbers should round to -infinity to ensure co-ordinates get placed in correct tile
		if (lat < 0 && lat % 100000 != 0) {
			tileLat--;
		}
		if (lon < 0 && lon % 100000 != 0) {
			tileLon--;
		}

		return keccak256(abi.encodePacked(tileLat, tileLon));
	}

	function addDrop(
		int256 lat,
		int256 lon,
		string memory message,
		uint256 duration
	) public {
		uint256 expiration = block.timestamp + duration;
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32 dropKey = getUniqueKey(lat, lon);

		Drop memory newDrop = Drop({
			sender: msg.sender,
			message: message,
			timestamp: block.timestamp,
			expiration: expiration,
			lat: lat,
			lon: lon
		});

		require(
			drops[tileKey][dropKey].timestamp == 0,
			"Drop already exists at this location"
		);

		drops[tileKey][dropKey] = newDrop;
		dropKeys[tileKey].push(dropKey);
		emit DropAdded(
			tileKey,
			msg.sender,
			message,
			block.timestamp,
			expiration,
			lat,
			lon
		);
	}

	function addMessage(
		int256 lat,
		int256 lon,
		uint16[] memory content,
		uint256 duration
	) public {
		uint256 expiration = block.timestamp + duration;
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32 messageKey = getUniqueKey(lat, lon);

		Message memory newMessage = Message({
			sender: msg.sender,
			content: content,
			timestamp: block.timestamp,
			expiration: expiration,
			lat: lat,
			lon: lon
		});

		require(
			messages[tileKey][messageKey].timestamp == 0,
			"Message already exists at this location"
		);

		messages[tileKey][messageKey] = newMessage;
		messageKeys[tileKey].push(messageKey);
		emit MessageAdded(
			tileKey,
			msg.sender,
			content,
			block.timestamp,
			expiration,
			lat,
			lon
		);
	}

	function getDropByCoordinates(
		int256 lat,
		int256 lon
	) public view returns (Drop memory) {
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32 dropKey = getUniqueKey(lat, lon);
		require(drops[tileKey][dropKey].timestamp != 0, "Drop does not exist");
		return drops[tileKey][dropKey];
	}

	function getMessageByCoordinates(
		int256 lat,
		int256 lon
	) public view returns (Message memory) {
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32 messageKey = getUniqueKey(lat, lon);
		require(
			messages[tileKey][messageKey].timestamp != 0,
			"Message does not exist"
		);
		return messages[tileKey][messageKey];
	}

	function getActiveDrops(
		int256 lat,
		int256 lon
	) public view returns (Drop[] memory) {
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32[] storage keys = dropKeys[tileKey];
		uint256 count = 0;
		uint256 index = 0;

		// First pass to count active drops
		for (uint256 i = 0; i < keys.length; i++) {
			if (drops[tileKey][keys[i]].expiration > block.timestamp) {
				count++;
			}
		}

		// Collect active drops
		Drop[] memory activeDrops = new Drop[](count);
		for (uint256 i = 0; i < keys.length; i++) {
			if (drops[tileKey][keys[i]].expiration > block.timestamp) {
				activeDrops[index] = drops[tileKey][keys[i]];
				index++;
			}
		}

		return activeDrops;
	}

	function getActiveMessages(
		int256 lat,
		int256 lon
	) public view returns (Message[] memory) {
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32[] storage keys = messageKeys[tileKey];
		uint256 count = 0;
		uint256 index = 0;

		for (uint256 i = 0; i < keys.length; i++) {
			if (messages[tileKey][keys[i]].expiration > block.timestamp) {
				count++;
			}
		}

		Message[] memory activeMessages = new Message[](count);
		for (uint256 i = 0; i < keys.length; i++) {
			if (messages[tileKey][keys[i]].expiration > block.timestamp) {
				activeMessages[index] = messages[tileKey][keys[i]];
				index++;
			}
		}

		return activeMessages;
	}

	function cleanUpExpiredDrops(int256 lat, int256 lon) public {
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32[] storage keys = dropKeys[tileKey];
		for (uint256 i = 0; i < keys.length; i++) {
			if (drops[tileKey][keys[i]].expiration <= block.timestamp) {
				delete drops[tileKey][keys[i]];
				keys[i] = keys[keys.length - 1];
				keys.pop();
				i--; // Check the same index again as it now has a new value
			}
		}
	}

	function cleanUpExpiredMessages(int256 lat, int256 lon) public {
		bytes32 tileKey = getTileKey(lat, lon);
		bytes32[] storage keys = messageKeys[tileKey];
		for (uint256 i = 0; i < keys.length; i++) {
			if (messages[tileKey][keys[i]].expiration <= block.timestamp) {
				delete messages[tileKey][keys[i]];
				keys[i] = keys[keys.length - 1];
				keys.pop();
				i--; // Check the same index again as it now has a new value
			}
		}
	}
}
