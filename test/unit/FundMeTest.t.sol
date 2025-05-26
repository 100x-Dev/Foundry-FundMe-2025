//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant Starting_Balance = 10 ether;

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        //me or us is calling -> FundMeTest -> FundMe (therefore owner of fundme here is fundmetest and not msg.sender(ie us))
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,Starting_Balance);
    } //always run first


    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    /*What can we to do to work with address outside our system?
  #1. Unit 
      - Testing a specefic part of our code 
  #2. Integration
      -Testing how our code works with other part of our code
  #3. Forked
      -Testing our code in a simulated environment 
  #4. Staging
      -Testing our code in a real environment that is not production 
*/
    /* THIS IS HOW WE TESTED THE PriceFeedVersion BEFORE THE CODE WAS HARDCODED FOR SEPOLIA ONLY
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }*/

    function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //this means the next line is expected to revert
        fundMe.fund();  //send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //THIS LINE IMPLIES THAT THE NEXT TX WILL BE SENT BY USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder =fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }


    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }


    function testWithDrawWithFromMultipleFunders() public funded{
        //Arrange
        uint160 numberOfFunders =10;
        uint160 startingFunderIndex =2;
        for (uint160 i= startingFunderIndex; i< numberOfFunders; i++){
            //we could use vm.prank to create new user adress and vm.deal to fund those address 
            //but we are using hoax here that does both the task together
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();



        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assert(startingFundMeBalance + startingOwnerBalance == endingOwnerBalance); //Instead of asserteq you can also use assert
    

    }

    function testWithDrawWithFromMultipleFundersCheaper() public funded{
        //Arrange
        uint160 numberOfFunders =10;
        uint160 startingFunderIndex =2;
        for (uint160 i= startingFunderIndex; i< numberOfFunders; i++){
            //we could use vm.prank to create new user adress and vm.deal to fund those address 
            //but we are using hoax here that does both the task together
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();



        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assert(startingFundMeBalance + startingOwnerBalance == endingOwnerBalance); //Instead of asserteq you can also use assert
    

    }

}
