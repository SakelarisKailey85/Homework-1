// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedLottery is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public lotteryToken;

    uint256 public ticketPrice;
    uint256 public ticketPool;
    uint256 public lotteryEndTime;

    address[] public participants;
    mapping(address => uint256) public tickets;

    event LotteryStarted(uint256 endTime);
    event LotteryTicketPurchased(address indexed participant, uint256 numTickets);
    event LotteryWinnerSelected(address indexed winner, uint256 prize);

    modifier onlyBeforeLotteryEnd() {
        require(block.timestamp < lotteryEndTime, "Lottery has ended");
        _;
    }

    modifier onlyAfterLotteryEnd() {
        require(block.timestamp >= lotteryEndTime, "Lottery has not ended");
        _;
    }

    constructor(address _lotteryToken, uint256 _ticketPrice, uint256 _lotteryDuration) {
        require(_lotteryToken != address(0), "Invalid token address");
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        require(_lotteryDuration > 0, "Lottery duration must be greater than 0");

        lotteryToken = IERC20(_lotteryToken);
        ticketPrice = _ticketPrice;
        lotteryEndTime = block.timestamp + _lotteryDuration;
    }
function purchaseTickets(uint256 _numTickets) external onlyBeforeLotteryEnd {
        require(_numTickets > 0, "Number of tickets must be greater than 0");

        uint256 totalCost = ticketPrice * _numTickets;

        // Transfer lottery tokens from the participant to the contract
        lotteryToken.safeTransferFrom(msg.sender, address(this), totalCost);

        // Update participant's ticket count
        tickets[msg.sender] += _numTickets;

        // Add participant to the list if they are not already included
        if (tickets[msg.sender] == _numTickets) {
            participants.push(msg.sender);
        }

        // Update ticket pool
        ticketPool += _numTickets;

        emit LotteryTicketPurchased(msg.sender, _numTickets);
    }
}
