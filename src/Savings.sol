// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Savings {
    event Saver(address payer, uint256 amount);
    mapping(address => uint256) public balances;
    mapping(address => uint256) public tenor;
    bool public openForWithdraw = false;
    uint256 public contractBalance = address(this).balance;

    // Collect funds in a payable `receive()` function and track individual `balances` with a mapping:
    // Add a `Saver(address,uint256, uint256, uint256)`
    receive() external payable {
        require(tenor[msg.sender] > 0, "You must set a tenor before saving");
        balances[msg.sender] += msg.value;
        contractBalance = address(this).balance;
        emit Saver(msg.sender, msg.value);
    }

    // Set the duration of time a user will save token in the contract.
    function setTenor(address saver, uint256 _tenor) public {
        tenor[saver] = block.timestamp + _tenor;
    }

    // Returns the duration of time a user is willing save funds in the contract.
    function getTenor(address saver) public view returns (uint256) {
        return tenor[saver];
    }

    // Returns the contract balance.
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Returns the balance saved in the contact by an address.
    function getIndividualBalances(
        address saver
    ) public view returns (uint256) {
        return balances[saver];
    }

    // Returns the time left before the tenor elapsed.
    function timeLeft(address saver) public view returns (uint256) {
        if (block.timestamp >= tenor[saver]) {
            return 0;
        } else {
            return tenor[saver] - block.timestamp;
        }
    }
    // Allows a user to withraw funds once the tenor has elapsed.
    function withdraw(uint amount, address withdrawer) public {
        if (timeLeft(withdrawer) <= 0) {
            openForWithdraw = true;
        }
        require(openForWithdraw, "It is not yet time to withdraw");
        require(
            balances[withdrawer] >= amount,
            "Balance less than amount to withdraw"
        );
        balances[withdrawer] -= amount;
        (bool success, ) = withdrawer.call{value: amount}("");
        require(success, "Unable to withdraw fund");
    }
}
