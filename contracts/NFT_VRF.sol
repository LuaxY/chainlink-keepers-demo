//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./Withdrawable.sol";

contract SuperNFTVRF is ERC721, ReentrancyGuard, Ownable, KeeperCompatibleInterface, VRFConsumerBase, Withdrawable {
    uint256 public constant PRICE = 0.005 ether;

    // Polygon Mumbai testnet values
    address private constant LINK_TOKEN_ADDRESS = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address private constant VRF_COORDINATOR_ADDRESS = 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255;
    bytes32 private constant VRF_KEY_HASH = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
    uint256 private constant VRF_FEE = 0.0001 * 10**18;

    uint256 public _counter = 0;

    uint256 public _lastRewardIndex = 0;

    IERC20 public _superToken;

    struct Winner {
        uint256 id;
        uint256 total;
        address owner;
        uint256 timestamp;
    }

    uint256 public _winnersCounter = 0;
    mapping(uint256 => Winner) public _winners;

    event NewWinner(uint256 id, uint256 nftId, address winner, uint256 timestamp);

    constructor(address superTokenAddress) ERC721("SuperNFT", "sNFT") VRFConsumerBase(VRF_COORDINATOR_ADDRESS, LINK_TOKEN_ADDRESS) {
        _superToken = IERC20(superTokenAddress);
    }

    function mint() public payable {
        require(msg.value >= PRICE, "mint: insufficient funds");
        _safeMint(msg.sender, _counter);
        _counter++;
        uint256 refund = msg.value - PRICE;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    }

    function _upkeepNeeded() public view returns (bool) {
        return (_counter > 0) && (_counter / 10) > _lastRewardIndex; // foor(_counter / 10) > _lastRewardIndex
    }

    function checkUpkeep(bytes calldata checkData) public view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = _upkeepNeeded();
    }

    function performUpkeep(bytes calldata performData) external override {
        require(_upkeepNeeded(), "performUpkeep: no upkeep needed");
        _lastRewardIndex++;
        getRandomNumber();
    }

    function getRandomNumber() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= VRF_FEE, "getRandomNumber: insufficient LINK");
        return requestRandomness(VRF_KEY_HASH, VRF_FEE);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        selectWinner(randomness);
    }

    function selectWinner(uint256 randomness) private nonReentrant {
        uint256 winnerId = randomness % _counter;
        address recipient = ownerOf(winnerId);
        _winners[_winnersCounter] = Winner(winnerId, _counter, recipient, block.timestamp);
        _superToken.transfer(recipient, 1 * 10**18);
        emit NewWinner(_winnersCounter, winnerId, recipient, block.timestamp);
        _winnersCounter++;
    }
}
