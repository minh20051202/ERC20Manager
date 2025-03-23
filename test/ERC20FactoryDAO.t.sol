//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Factory} from "../src/ERC20Factory.sol";
import {DeployERC20Factory} from "../script/ERC20Factory.s.sol";
import {ERC20Manager} from "../src/ERC20Manger.sol";
import {MultisigDAO} from "../src/MultisigDAO.sol";

contract ERC20FactoryDAOTest is Test {
    ERC20Factory erc20Factory;
    MultisigDAO multiSigDAO;
    address token;
    address[] owners;
    uint256 constant OWNER_LENGTH = 3;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployERC20Factory deployer = new DeployERC20Factory();
        erc20Factory = deployer.run();
        for (uint160 i = 1; i < OWNER_LENGTH + 1; i++) {
            owners.push(address(i));
        }
        erc20Factory.mintERC20ForDAO(owners, 2, "Hello", "H", 18, 1e18);
        token = erc20Factory.getListOfERC20DAOCreated()[0];
        multiSigDAO = MultisigDAO(erc20Factory.getDAOAddressOfERC20DAO(token));
    }

    function testSubmitApproveAndExecuteBurnProposal() public {
        uint256 beforeDAOBalance = ERC20Manager(token).balanceOf(
            address(multiSigDAO)
        );
        console.log(beforeDAOBalance);
        vm.prank(address(1));
        multiSigDAO.submitProposal(
            address(2),
            1e17,
            MultisigDAO.Action.Burn,
            ""
        );
        vm.prank(address(2));
        multiSigDAO.approveProposal(0);
        vm.prank(address(3));
        multiSigDAO.approveProposal(0);
        vm.prank(address(1));
        multiSigDAO.executeProposal(0);
        uint256 afterDAOBalance = ERC20Manager(token).balanceOf(
            address(multiSigDAO)
        );
        console.log(afterDAOBalance);
        assertEq(afterDAOBalance, beforeDAOBalance - 1e17);
    }

    function testSubmitApproveAndExecuteMintProposal() public {
        uint256 beforeUserBalance = ERC20Manager(token).balanceOf(address(2));
        uint256 beforeDAOBalance = ERC20Manager(token).balanceOf(
            address(multiSigDAO)
        );
        vm.prank(address(1));
        multiSigDAO.submitProposal(
            address(2),
            1e17,
            MultisigDAO.Action.Mint,
            ""
        );
        vm.prank(address(2));
        multiSigDAO.approveProposal(0);
        vm.prank(address(3));
        multiSigDAO.approveProposal(0);
        vm.prank(address(1));
        multiSigDAO.executeProposal(0);
        uint256 afterUserBalance = ERC20Manager(token).balanceOf(address(2));
        uint256 afterDAOBalance = ERC20Manager(token).balanceOf(
            address(multiSigDAO)
        );
        assertEq(
            beforeUserBalance + beforeDAOBalance,
            afterDAOBalance + afterUserBalance
        );
    }
}
