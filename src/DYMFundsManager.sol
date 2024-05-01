// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@solmate/src/utils/ReentrancyGuard.sol";

// This -> Minter -> Dex

contract DYMFundsManager is Ownable, ReentrancyGuard {
    /// @dev Errors
    error DFM__ZeroAmount();
    error DFM__InvalidMeme();
    error DFM__MemeDead();
    error DFM__TransferFailed();
    error DFM__NothingToRefund();

    /// @dev Constants
    uint256 private constant SUPPLY = 1000000;
    uint256 private constant HYPER = 1 ether;

    /// @dev Variables
    uint256 private s_totalMemes;

    /// @dev Enums
    enum MemeStatus {
        ALIVE,
        DEAD
    }

    /// @dev Structs
    struct Meme {
        address idToCreator;
        string idToName;
        string idToSymbol;
        uint256 idToTimeLeft;
        uint256 idToTotalFunds;
        address[] idToFunders;
        mapping(address => uint256) idToFunderToFunds;
        MemeStatus idToMemeStatus;
    }

    /// @dev Mappings
    mapping(uint256 => Meme) private s_memes;
    mapping(address => uint256) private s_funderToFunds;

    /// @dev Events
    event MemeCreated(address indexed creator, string name, string symbol);
    event MemeFunded(uint256 id, uint256 value);
    event RefundPerformed(address funder, uint256 amount);

    /// @dev Constructor
    constructor() Ownable(msg.sender) {}

    /** @notice It is creating new meme with basic ERC20 data and starts timer, which is telling if meme is alive or dead */
    /** @param name Meme id that we want to work with */
    /** @param symbol Meme id that we want to work with */
    function createMeme(string calldata name, string calldata symbol) external {
        Meme storage meme = s_memes[s_totalMemes];

        meme.idToCreator = msg.sender;
        meme.idToName = name;
        meme.idToSymbol = symbol;
        meme.idToTimeLeft = block.timestamp + 30 days;
        meme.idToMemeStatus = MemeStatus.ALIVE;

        s_totalMemes += 1;

        emit MemeCreated(msg.sender, name, symbol);
    }

    // This will send request to Minter for creation of meme
    function hypeMeme() external {}

    /** @notice If meme fails to achieve fund goal on time this function will assign funds back to funders wallets and change state of meme to dead */
    /** @param id Meme id that we want to work with */
    function killMeme(uint256 id) external {
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        address[] memory funders = meme.idToFunders;

        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            uint256 funds = meme.idToFunderToFunds[funder];

            s_funderToFunds[funder] += funds;
            meme.idToFunderToFunds[funder] = 0;
        }

        meme.idToMemeStatus = MemeStatus.DEAD;
    }

    /** @notice Allows to send funds for given meme */
    /** @param id Meme id that we want to work with */
    function fundMeme(uint256 id) external payable {
        if (msg.value <= 0) revert DFM__ZeroAmount();
        if (id >= s_totalMemes) revert DFM__InvalidMeme();
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        meme.idToTotalFunds += msg.value;
        meme.idToFunders.push(msg.sender);
        meme.idToFunderToFunds[msg.sender] += msg.value;

        emit MemeFunded(id, msg.value);
    }

    /** @notice Allows user to withdraw funds from dead memes if user has any */
    function refund() external nonReentrant {
        uint256 amount = s_funderToFunds[msg.sender];

        if (amount > 0) {
            s_funderToFunds[msg.sender] = 0;
        } else {
            revert DFM__NothingToRefund();
        }

        (bool success, ) = msg.sender.call{value: amount}("");

        if (!success) {
            s_funderToFunds[msg.sender] = amount;
            revert DFM__TransferFailed();
        }

        emit RefundPerformed(msg.sender, amount);
    }

    function getFunderToFunds(address funder) external view returns (uint256) {
        return s_funderToFunds[funder];
    }

    /** @notice Temporary function for testing purposes -> it should be replaced with GraphQl */
    /** @notice Gets all data associated with given meme */
    /** @param id Meme id that we want to work with */
    function getMemeData(
        uint256 id
    ) external view returns (address, string memory, string memory, uint256, uint256, address[] memory, uint256[] memory funds, MemeStatus) {
        Meme storage meme = s_memes[id];

        funds = new uint256[](meme.idToFunders.length);

        for (uint i; i < meme.idToFunders.length; i++) {
            funds[i] = meme.idToFunderToFunds[meme.idToFunders[i]];
        }

        return (meme.idToCreator, meme.idToName, meme.idToSymbol, meme.idToTimeLeft, meme.idToTotalFunds, meme.idToFunders, funds, meme.idToMemeStatus);
    }
}
