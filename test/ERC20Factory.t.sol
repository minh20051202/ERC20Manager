//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Factory} from "../src/ERC20Factory.sol";
import {DeployERC20Factory} from "../script/ERC20Factory.s.sol";
import {ERC20Manager} from "../src/ERC20Manger.sol";

contract ERC20FactoryTest is Test {
    ERC20Factory erc20Factory;
    address public USER_NUMBER_1 = makeAddr("userNumber1");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    modifier mint() {
        vm.prank(USER_NUMBER_1);
        erc20Factory.mintERC20Manager("Hello", "H", 18, 1e18);
        _;
    }

    function setUp() external {
        DeployERC20Factory deployer = new DeployERC20Factory();
        erc20Factory = deployer.run();
        vm.deal(USER_NUMBER_1, STARTING_USER_BALANCE);
    }

    function testGetTotalSupplyOfERC20() public mint {
        address owner = erc20Factory.getOwnerOfERC20(
            erc20Factory.getListOfERC20(USER_NUMBER_1)[0]
        );
        address token = erc20Factory.getListOfERC20(USER_NUMBER_1)[0];
        assertEq(ERC20Manager(token).balanceOf(owner), 1e18);
    }
}
