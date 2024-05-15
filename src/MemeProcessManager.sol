// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@solmate/utils/ReentrancyGuard.sol";
import {IMemeCoinMinter} from "./Interfaces/IMemeCoinMinter.sol";
import {KeeperCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

/**
 * @dev Contract responsible for creating memes
 * It allows to fund created alive memes and gives ability to restore funders funds if certain meme fails dexing
 * It also filtrates memes that can be dexed from those, which are not worth further processing
 * This contract is automated and does above with help of Chainlink Keepers, so whole dexing process starts here automatically
 */

contract MemeProcessManager is Ownable, ReentrancyGuard, KeeperCompatibleInterface {
    /// @dev Errors
    error DFM__ZeroAmount();
    error DFM__InvalidMeme();
    error DFM__MemeDead();
    error DFM__TransferFailed();
    error DFM__NothingToRefund();
    error DFM__UpkeepNotNeeded();

    /// @dev Constants
    uint private constant HYPE = 1 ether;

    /// @dev Immutables
    address private immutable i_mcm;
    address private immutable i_dym;
    uint private immutable i_interval;

    /// @dev Variables
    uint private s_totalMemes;
    uint private s_lastTimeStamp;

    /// @dev Arrays
    uint[] private s_unprocessedMemes;

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
    event MemeFunded(uint indexed id, uint indexed value);
    event RefundPerformed(address indexed funder, uint indexed amount);
    event MemeKilled(uint indexed id);
    event MemeHyped(uint indexed id);
    event TransferSuccessfull(uint indexed amount);
    event MemesProcessed(bool indexed performed);

    /// @dev Constructor
    constructor(address mcm, address dym, uint interval) Ownable(msg.sender) {
        i_mcm = mcm;
        i_dym = dym;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    //////////////////////////////////// @notice DFM External Functions ////////////////////////////////////

    /// @notice It is creating new meme with basic ERC20 data and starts timer, which is telling if meme is alive or dead
    /// @param name Meme id that we want to work with
    /// @param symbol Meme id that we want to work with
    function createMeme(string calldata name, string calldata symbol) external {
        Meme storage meme = s_memes[s_totalMemes];

        meme.idToCreator = msg.sender;
        meme.idToName = name;
        meme.idToSymbol = symbol;
        meme.idToTimeLeft = (block.timestamp + 30 days);

        s_unprocessedMemes.push(s_totalMemes);
        s_totalMemes += 1;

        emit MemeCreated(msg.sender, name, symbol);
    }

    /// @notice Allows to send funds for given meme
    /// @param id Meme id that we want to work with
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

    /// @notice Allows users to withdraw funds from dead memes
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

    //////////////////////////////////// @notice DFM Internal Functions ////////////////////////////////////

    /// @notice Sends request to MCM for creation of meme
    /// @param id Meme id that we want to work with
    function hypeMeme(uint id) internal {
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        address[] memory recipients = meme.idToFunders;
        uint[] memory amounts = new uint[](recipients.length);

        for (uint i; i < recipients.length; i++) {
            amounts[i] = meme.idToFunderToFunds[recipients[i]];
        }

        /// @dev Calling mint token fn from MCM contract
        IMemeCoinMinter.MintParams memory params = IMemeCoinMinter.MintParams({
            name: meme.idToName,
            symbol: meme.idToSymbol,
            creator: meme.idToCreator,
            team: owner(),
            recipients: recipients,
            amounts: amounts,
            totalFunds: meme.idToTotalFunds,
            dym: i_dym
        });

        IMemeCoinMinter(i_mcm).mintCoinAndRequestDex(params);

        /// @dev If success, sending funds directly to DYM contract
        (bool success, ) = i_dym.call{value: meme.idToTotalFunds}("");
        if (!success) revert DFM__TransferFailed();

        emit TransferSuccessfull(meme.idToTotalFunds);
        emit MemeHyped(id);
    }

    /// @notice If meme fails to achieve fund goal on time this function will assign funds back to funders wallets and change state of meme to dead
    /// @param id Meme id that we want to work with
    function killMeme(uint id) internal {
        Meme storage meme = s_memes[id];
        if (meme.idToMemeStatus == MemeStatus.DEAD) revert DFM__MemeDead();

        address[] memory funders = meme.idToFunders;

        for (uint i; i < funders.length; i++) {
            address funder = funders[i];
            uint funds = meme.idToFunderToFunds[funder];

            s_funderToFunds[funder] += funds;
            meme.idToFunderToFunds[funder] = 0;
        }

        emit MemeKilled(id);
    }

    //////////////////////////////////// @notice DFM Chainlink Automation Functions ////////////////////////////////////

    /// @notice Checks if the contract requires work to be done
    /// @param 'checkData' Data passed to the contract when checking for upkeep
    /// @return upkeepNeeded Boolean to indicate whether the keeper should call performUpkeep or not
    /// @return 'performData' Bytes that the keeper should call performUpkeep with, if upkeep is needed
    function checkUpkeep(bytes memory /* checkData */) public view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasMemesToProcess = s_unprocessedMemes.length > 0;

        upkeepNeeded = (timePassed && hasMemesToProcess);

        return (upkeepNeeded, "0x0");
    }

    /// @notice Performs work on the contract. Executed by the keepers, via the registry
    /// @param 'performData' is the data which was passed back from the checkData simulation
    function performUpkeep(bytes calldata /* performData */) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");

        if (!upkeepNeeded) revert DFM__UpkeepNotNeeded();

        uint[] memory unprocessedMemes = s_unprocessedMemes;

        for (uint i; i < unprocessedMemes.length; i++) {
            uint memeId = unprocessedMemes[i];
            Meme storage meme = s_memes[memeId];

            if (meme.idToMemeStatus == MemeStatus.ALIVE) {
                if (meme.idToTotalFunds >= HYPE) hypeMeme(memeId);

                if (meme.idToTimeLeft < block.timestamp && meme.idToTotalFunds < HYPE) killMeme(memeId);

                meme.idToMemeStatus = MemeStatus.DEAD;
            }
        }

        s_unprocessedMemes = new uint[](0);
        s_lastTimeStamp = block.timestamp;

        emit MemesProcessed(true);
    }

    //////////////////////////////////// @notice DFM Getter Functions ////////////////////////////////////

    /// @notice Temporary function for testing purposes -> it should be replaced with GraphQl
    /// @notice Returns total funds available for refund for given funder
    /// @param funder wallet address of funder
    function getFunderToFunds(address funder) external view returns (uint) {
        return s_funderToFunds[funder];
    }

    /// @notice Temporary function for testing purposes -> it should be replaced with GraphQl
    /// @notice Returns all data associated with given meme
    /// @param id Meme id that we want to work with
    function getMemeData(uint id) external view returns (address, string memory, string memory, uint, uint, address[] memory, uint[] memory funds, MemeStatus) {
        Meme storage meme = s_memes[id];

        funds = new uint[](meme.idToFunders.length);

        for (uint i; i < meme.idToFunders.length; i++) {
            funds[i] = meme.idToFunderToFunds[meme.idToFunders[i]];
        }

        return (meme.idToCreator, meme.idToName, meme.idToSymbol, meme.idToTimeLeft, meme.idToTotalFunds, meme.idToFunders, funds, meme.idToMemeStatus);
    }
}