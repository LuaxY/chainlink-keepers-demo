//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SuperToken is ERC20 {
    constructor() ERC20("SuperToken", "sTKN") {
        _mint(msg.sender, 100 * 10**18); // 100 sTKN
    }
}
