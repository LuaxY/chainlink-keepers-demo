//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract Counter is KeeperCompatibleInterface {
    /**
     * Public counter variable
     */
    uint256 public counter;

    /**
     * Use an interval in seconds and a timestamp to slow execution of Upkeep
     */
    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    constructor(uint256 updateInterval) {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;

        counter = 0;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory performData
        )
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        performData = "0x";
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        lastTimeStamp = block.timestamp;
        counter = counter + 1;
    }
}
