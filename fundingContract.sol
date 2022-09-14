//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract fundingContract {
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }
    

    function fund() public payable {
        uint256 minimumAmt = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumAmt, "Need more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return pricefeed.version();
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        (,int price,,,) = pricefeed.latestRoundData();
        return uint256(price * 10 ** 10); // 1595.16000000
    }

    function getConversionRate(uint256 ethAmt) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethPriceInUsd = (ethPrice * ethAmt) / 10 ** 18;
        return ethPriceInUsd;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function withdraw() payable onlyOwner public {
        owner.transfer(address(this).balance);

        for(uint256 i=0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

}