//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "./Withdrawable.sol";

contract SuperNFT is ERC721, ReentrancyGuard, Ownable, KeeperCompatibleInterface, Withdrawable {
    uint256 public constant PRICE = 0.005 ether;

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

    constructor(address superTokenAddress) ERC721("SuperNFT", "sNFT") {
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

        // Not secure, do not use in production
        selectWinner(uint256((blockhash(block.number - 1))));
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
