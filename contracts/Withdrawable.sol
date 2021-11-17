//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Withdrawable is Ownable {
    function withdrawEthers(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "withdrawEthers: insufficient ethers");
        payable(msg.sender).transfer(amount);
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "withdrawTokens: insufficient tokens");
        token.transfer(msg.sender, amount);
    }
}
