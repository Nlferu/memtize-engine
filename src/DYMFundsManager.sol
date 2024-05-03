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
    error DFM__MinterCallFailed();

    /// @dev Constants
    uint private constant HYPER = 1 ether;

    /// @dev Variables
    uint private s_totalMemes;

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
        uint idToTimeLeft;
        uint idToTotalFunds;
        address[] idToFunders;
        mapping(address => uint) idToFunderToFunds;
        MemeStatus idToMemeStatus;
    }

    /// @dev Mappings
    mapping(uint => Meme) private s_memes;
    mapping(address => uint) private s_funderToFunds;

    /// @dev Events
    event MemeCreated(address indexed creator, string name, string symbol);
    event MemeFunded(uint id, uint value);
    event RefundPerformed(address funder, uint amount);
    event MemeKilled(uint id);
    event MemeHyped(uint id);

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

        s_totalMemes += 1;

        emit MemeCreated(msg.sender, name, symbol);
    }

    /** @notice Sends request to MCM for creation of meme */
    /** @param id Meme id that we want to work with */
    function hypeMeme(uint id, address memeCoinMinter) external {
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        address[] memory recipients = meme.idToFunders;
        uint[] memory amounts = new uint[](recipients.length);

        for (uint i; i < recipients.length; i++) {
            amounts[i] = meme.idToFunderToFunds[recipients[i]];
        }

        (bool success, ) = memeCoinMinter.call{value: meme.idToTotalFunds}(
            abi.encodeWithSignature("mintToken(string,string,address[],uint256[])", meme.idToName, meme.idToSymbol, recipients, amounts)
        );

        if (!success) revert DFM__MinterCallFailed();

        meme.idToMemeStatus = MemeStatus.DEAD;

        emit MemeHyped(id);
    }

    /** @notice If meme fails to achieve fund goal on time this function will assign funds back to funders wallets and change state of meme to dead */
    /** @param id Meme id that we want to work with */
    function killMeme(uint id) external {
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        address[] memory funders = meme.idToFunders;

        for (uint i; i < funders.length; i++) {
            address funder = funders[i];
            uint funds = meme.idToFunderToFunds[funder];

            s_funderToFunds[funder] += funds;
            meme.idToFunderToFunds[funder] = 0;
        }

        meme.idToMemeStatus = MemeStatus.DEAD;

        emit MemeKilled(id);
    }

    /** @notice Allows to send funds for given meme */
    /** @param id Meme id that we want to work with */
    function fundMeme(uint id) external payable {
        if (msg.value <= 0) revert DFM__ZeroAmount();
        if (id >= s_totalMemes) revert DFM__InvalidMeme();
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        meme.idToTotalFunds += msg.value;
        if (meme.idToFunderToFunds[msg.sender] == 0) meme.idToFunders.push(msg.sender);
        meme.idToFunderToFunds[msg.sender] += msg.value;

        emit MemeFunded(id, msg.value);
    }

    /** @notice Allows user to withdraw funds from dead memes if user has any */
    function refund() external nonReentrant {
        uint amount = s_funderToFunds[msg.sender];

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

    /** @notice Temporary function for testing purposes -> it should be replaced with GraphQl */
    /** @notice Returns total funds available for refund for given funder */
    /** @param funder wallet address of funder */
    function getFunderToFunds(address funder) external view returns (uint) {
        return s_funderToFunds[funder];
    }

    /** @notice Temporary function for testing purposes -> it should be replaced with GraphQl */
    /** @notice Returns all data associated with given meme */
    /** @param id Meme id that we want to work with */
    function getMemeData(uint id) external view returns (address, string memory, string memory, uint, uint, address[] memory, uint[] memory funds, MemeStatus) {
        Meme storage meme = s_memes[id];

        funds = new uint[](meme.idToFunders.length);

        for (uint i; i < meme.idToFunders.length; i++) {
            funds[i] = meme.idToFunderToFunds[meme.idToFunders[i]];
        }

        return (meme.idToCreator, meme.idToName, meme.idToSymbol, meme.idToTimeLeft, meme.idToTotalFunds, meme.idToFunders, funds, meme.idToMemeStatus);
    }
}
