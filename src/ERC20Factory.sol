// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Manager} from "./ERC20Manger.sol";
import {MultisigDAO} from "./MultisigDAO.sol";

contract ERC20Factory {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address[] private s_erc20;
    address[] private s_erc20DAO;
    address[] private s_listOfDAO;
    mapping(address => address[]) s_addressToListOfERC20;
    mapping(address => address) s_daoAddressToERC20;
    mapping(address => address) s_ERC20ToOwner;
    mapping(address => address) s_ERC20toDAO;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Create(
        address indexed owner,
        address indexed token,
        uint256 indexed amount
    );

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function mintERC20(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _amount
    ) public {
        ERC20Manager erc20 = new ERC20Manager(
            _name,
            _symbol,
            _decimals,
            _amount,
            msg.sender
        );
        s_erc20.push(address(erc20));
        s_addressToListOfERC20[msg.sender].push(address(erc20));
        emit Create(msg.sender, address(erc20), erc20.totalSupply());
    }

    function mintERC20ForDAO(
        address[] memory _owners,
        uint256 _required,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _amount
    ) public {
        MultisigDAO multiSigDAO = new MultisigDAO(
            _owners,
            _required,
            _name,
            _symbol,
            _decimals,
            _amount
        );
        address token = address(multiSigDAO.erc20Manager());
        address daoAddress = address(multiSigDAO);
        s_listOfDAO.push(daoAddress);
        s_erc20DAO.push(token);
        s_ERC20toDAO[token] = daoAddress;
        s_daoAddressToERC20[daoAddress] = token;
        emit Create(daoAddress, token, ERC20Manager(token).totalSupply());
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function getListOfERC20(
        address user
    ) public view returns (address[] memory) {
        return s_addressToListOfERC20[user];
    }

    function getOwnerOfERC20(address token) public view returns (address) {
        return s_ERC20ToOwner[token];
    }

    function getListOfERC20Created() public view returns (address[] memory) {
        return s_erc20;
    }

    function getDAOAddressOfERC20DAO(
        address token
    ) public view returns (address) {
        return s_ERC20toDAO[token];
    }

    function getListOfDAO() public view returns (address[] memory) {
        return s_listOfDAO;
    }

    function getListOfERC20DAOCreated() public view returns (address[] memory) {
        return s_erc20DAO;
    }

    function getERC20MetadataOfDAO(
        address dao
    )
        public
        view
        returns (address, string memory, string memory, uint8, uint256)
    {
        ERC20Manager erc20DAO = ERC20Manager(s_daoAddressToERC20[dao]);
        string memory tokenName = erc20DAO.name();
        string memory symbol = erc20DAO.symbol();
        uint8 decimals = erc20DAO.decimals();
        uint256 totalSupply = erc20DAO.totalSupply();
        return (address(erc20DAO), tokenName, symbol, decimals, totalSupply);
    }

    function getDAOProposals(
        address daoAddress
    ) public view returns (MultisigDAO.Proposal[] memory) {
        return MultisigDAO(daoAddress).getProposals();
    }
}
