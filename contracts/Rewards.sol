// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// assuming each address can send ether to the contract, and rewards will be based on that.
contract Rewards {
    address owner;
    mapping(address => uint) public contributions;
    mapping(address => uint) public rewards;

    mapping(address => bool) public contributorExist;
    address[] contributors;
    uint ammCurrentTotal;

    //sets the owner to sender
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not the Owner');
        _;
    }

    // this will be triggered externally by the owner of the contract every month;
    function disburseRewards() external onlyOwner {
        require(ammCurrentTotal!=0, "No rewards to be disbursed");
        for (uint i=0; i<contributors.length; i++) {
            rewards[contributors[i]] += contributions[msg.sender]/ammCurrentTotal;
        }
        ammCurrentTotal = 0;
    }
    
    function contribute() external payable {
        if(!contributorExist[msg.sender]){
            contributorExist[msg.sender] = true;
            contributors.push(msg.sender);
        }
        contributions[msg.sender]+=msg.value;
        ammCurrentTotal += msg.value;
    }

    function withdraw(uint amount) external {
        require(amount <= contributions[msg.sender]);
        contributions[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success, 'fund transfer failed');
    }

    function withdrawRewards() external {
        require(contributions[msg.sender]>0, "Need to contribute to get reward");
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value:reward}("");
        require(success, 'fund transfer failed');
    }
}
