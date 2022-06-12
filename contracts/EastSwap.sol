pragma solidity ^0.5.1;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract IEasySwap {
    function acquire(bytes32 secretCode) external;
    function refund_and_complete() external;
}


contract EasySwap is IEasySwap {
    // Use SafeMath contract from openzeppelin-solidity for more safe math
    using SafeMath for uint256;

    address payable public giverAddress;
    address payable public receiverAddress;
    uint public swapAmount;
    uint public swapTimeUntil;
    uint public lockTimeUntil;
    bytes32 public secretHash;

    constructor(
        address payable _giverAddress,
        address payable _receiverAddress,
        uint _swapAmount,
        uint _swapTimeUntil,
        uint _lockTimeUntil,
        bytes32 _secretHash
    )
        public payable
    {
        if (_swapTimeUntil >= _lockTimeUntil) {
            revert("Swap time can not be larger than lock time");
        }
        giverAddress = _giverAddress;
        receiverAddress = _receiverAddress;
        swapAmount = _swapAmount;
        swapTimeUntil = _swapTimeUntil;
        lockTimeUntil = _lockTimeUntil;
        secretHash = _secretHash;
    }

    function() external {
        revert("No sending funds allowed");
    }

    function acquire(bytes calldata secretCode) external {
        if (msg.sender != receiverAddress) {
            revert("Who acquire funds should be the receiver");
        }

        if (keccak256(secretCode) == secretHash)

        // Send predetermined amount of funds to receiver
        receiverAddress.transfer(swapAmount);
    }

    function refund_and_complete() external {
        // Common peer would dispose block with 15 seconds future timestamp
        // It is OK to use block.timestamp here
        if (block.timestamp <= lockTimeUntil) {
            revert("Can not refund during locktime");
        }

        // Selfdestruct the contract. Remaining funds goes back to original giver
        selfdestruct(giverAddress);
    }
}