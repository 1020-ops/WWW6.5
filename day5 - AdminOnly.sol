// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly{
    address public owner;
    uint256 public treasureAmount;

    mapping (address => uint256) public withdrawalAllowance;
    mapping (address => bool) public hasWithdraw;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied: Only the owner can perform this action.");
        _;
    }

    function addTreasure(uint256 amount) public onlyOwner{
        treasureAmount += amount;
    }

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner{
        require(amount <= treasureAmount, "Not enough treasure available!");
        withdrawalAllowance[recipient] = amount;
    }

    function withdrawTreasure(uint256 amount) public {
        if (msg.sender == owner){
            require(amount <= treasureAmount, "Not enough treasure available!");
            treasureAmount -= amount;
            return;
        }else{
            uint256 allowance = withdrawalAllowance[msg.sender];
            require(allowance > 0, "You need to approve enough allowance!");
            require(!hasWithdraw[msg.sender], "You have already withdrawn your treasure!");
            require(allowance <= treasureAmount, "Not have enough allowance!");
            hasWithdraw[msg.sender] = true;
            treasureAmount -= allowance;
            withdrawalAllowance[msg.sender] = 0;
        }
    }

    function resetWithdrawlStatus(address user) public onlyOwner{
        hasWithdraw[user] = false;
    }

    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Invalid address!");
        owner = newOwner;
    }

    function getTreasureDetails() public view onlyOwner returns(uint256){
        return treasureAmount;
    }
}