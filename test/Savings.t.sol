// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import dependencies
import "forge-std/Test.sol";
import "../src/Savings.sol";
import "forge-std/console.sol";

//Test Contract
contract TestSavings is Test {
    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    Savings public savings;

    // Allow the test contract to receive funds.
    receive() external payable {}

    // Initial configuration.
    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        savings = new Savings();
    }

    // The initial balance should be 0.
    function testInitialBalance() public view {
        assertLt(savings.getBalance(), 1);
    }

    // User should not be able to save without setting a tenor.
    function testSavingsWithoutTenor() public {
        vm.deal(address(this), 2 ether);
        vm.expectRevert();
        (bool sent, ) = address(savings).call{value: 1 ether}("");
        require(sent, "Failed to send Ether");
    }

    // User should be able to set tenor.
    function testSetTenor() public {
        savings.setTenor(address(this), 30);
        uint tenor = savings.getTenor(address(this));
        assertGt(tenor, block.timestamp);
    }

    // User should be able to save, if the user has set a tenor.
    function testSavings() public {
        savings.setTenor(address(this), 30);
        vm.deal(address(this), 2 ether);
        (bool sent, ) = address(savings).call{value: 1 ether}("");
        require(sent, "Failed to send Ether");
        assertGt(savings.getIndividualBalances(address(this)), 0);
    }

    // User should not be able to with the tenor elapses.
    function testWithdrawBeforeTime() public {
        savings.setTenor(address(this), 30);
        vm.deal(address(this), 2 ether);
        (bool sent, ) = address(savings).call{value: 1 ether}("");
        console.log(sent);
        vm.expectRevert("It is not yet time to withdraw");
        savings.withdraw(0.5 ether, address(this));
    }

    // User should be able to withdraw after the tenor elapses.
    function testWithdrawAfterTime() public {
        savings.setTenor(address(this), 0);
        vm.deal(address(this), 1 ether);
        (bool sent, ) = address(savings).call{value: 1 ether}("");
        console.log(sent);
        uint256 oldBalance = address(this).balance;
        savings.withdraw(0.5 ether, address(this));
        uint256 newBalance = address(this).balance;
        assertGt(newBalance, oldBalance);
    }
}
